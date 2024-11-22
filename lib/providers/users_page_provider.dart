import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:vchat/models/chat.dart';
import 'package:vchat/pages/chat_page.dart';
import '../services/database_service.dart';
import '../providers/authentication_provider.dart';
import '../models/chat_user.dart';

class UsersPageProvider extends ChangeNotifier {
  late final AuthenticationProvider _auth;
  late DatabaseService _database;
  List<ChatUser>? users;
  final List<ChatUser> _selectedUsers = [];

  UsersPageProvider(this._auth) {
    _database = GetIt.instance.get<DatabaseService>();
    getUsers();
  }

  List<ChatUser> get selectedUsers => _selectedUsers;

  void getUsers({String? name}) async {
    QuerySnapshot snapshot = await _database.getUsers(name: name);
    if (snapshot.docs.isNotEmpty) {
      users = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["uid"] = doc.id;
        return ChatUser.fromJSON(data);
      }).toList();
    } else {
      users = [];
    }
    notifyListeners();
  }

  void updateSelectedUsers(ChatUser user) {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
    } else {
      _selectedUsers.add(user);
    }
    notifyListeners();
  }

  Future<void> createChat(BuildContext context) async {
    try {
      List<String> membersIds = _selectedUsers.map((user) => user.uid).toList();
      membersIds.add(_auth.userInfo.uid);
      bool isGroup = _selectedUsers.length > 1;

      DocumentReference? chatDoc = await _database.createChat({
        "is_group": isGroup,
        "is_activity": false,
        "members": membersIds,
        "created_at": FieldValue.serverTimestamp(),
        "last_message": null,
      });

      if (chatDoc != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chat: Chat(
                uid: chatDoc.id,
                currentUserUid: _auth.userInfo.uid,
                members: [..._selectedUsers, _auth.userInfo],
                messages: [],
                activity: false,
                group: isGroup,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      logger.e('Error creating chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat: $e')),
      );
    }
  }
}
