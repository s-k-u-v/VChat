import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../services/database_service.dart';
import '../providers/authentication_provider.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  late final AuthenticationProvider _auth;
  late DatabaseService _db;
  List<Chat> chats = [];
  StreamSubscription? _chatsStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _chatsStream?.cancel();
    super.dispose();
  }

  void getChats() {
    try {
      _chatsStream = _db.getChatsForUser(_auth.userInfo.uid).listen(
        (snapshot) async {
          _logger.i('Fetched ${snapshot.docs.length} chat documents');

          // Use Future.wait to process all chat documents concurrently
          chats = await Future.wait(
            snapshot.docs.map((doc) async {
              // Ensure we always return a Chat object
              try {
                Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;
                
                // Fetch members for each chat
                List<ChatUser> members = [];
                for (var uid in chatData["members"] ?? []) {
                  DocumentSnapshot? userSnapshot = await _db.getUser(uid);
                  
                  if (userSnapshot != null && userSnapshot.exists) {
                    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
                    userData["uid"] = userSnapshot.id;
                    members.add(ChatUser.fromJSON(userData));
                  }
                }

                // Fetch last message
                List<ChatMessage> messages = [];
                QuerySnapshot lastMessageSnapshot = await _db.getLastMessageForChat(doc.id);
                
                if (lastMessageSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic> messageData = 
                      lastMessageSnapshot.docs.first.data() as Map<String, dynamic>;
                  messages.add(ChatMessage.fromJSON(messageData));
                }

                // Always return a Chat object
                return Chat(
                  uid: doc.id,
                  currentUserUid: _auth.userInfo.uid,
                  members: members,
                  messages: messages,
                  activity: chatData["is_activity"] ?? false,
                  group: chatData["is_group"] ?? false,
                );
              } catch (e) {
                _logger.e('Error processing individual chat: $e');
                // Return a fallback Chat object instead of null
                return Chat(
                  uid: doc.id,
                  currentUserUid: _auth.userInfo.uid,
                  members: [],
                  messages: [],
                  activity: false,
                  group: false,
                );
              }
            }),
          );

          _logger.i('Processed ${chats.length} valid chats');
          notifyListeners();
        },
        onError: (error) {
          _logger.e('Error fetching chats: $error');
        },
      );
    } catch (e) {
      _logger.e('Exception in getChats: $e');
    }
  }
}