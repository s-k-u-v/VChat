import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

final Logger logger = Logger();

const String userCollection = "Users";
const String chatCollection = "Chats";
const String messagesCollection = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email, String name, String imageURL) async {
    await _db.collection(userCollection).doc(uid).set({
      "email": email,
      "image": imageURL,
      "last_active": DateTime.now().toUtc(),
      "name": name,
    });
  }

  Future<DocumentSnapshot<Object?>?> getUser(String uid) async {
    try {
      return await _db.collection(userCollection).doc(uid).get();
    } catch (e) {
      logger.e("Error fetching user with uid: $uid, error: $e");
      return null; // Return null if an error occurs
    }
  }

  Future<QuerySnapshot> getUsers({String? name}) async {
    Query query = _db.collection(userCollection);
    if (name != null) {
      query = query.where("name", isGreaterThanOrEqualTo: name).where("name", isLessThanOrEqualTo: "${name}z");
    }
    return query.get();
  }

  Stream<QuerySnapshot> getChatsForUser(String uid) {
    return _db.collection(chatCollection).where('members', arrayContains: uid).snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String chatID) async {
    return await _db.collection(chatCollection).doc(chatID).collection(messagesCollection).orderBy("sent_time", descending: true).limit(1).get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String chatID) {
    return _db.collection(chatCollection).doc(chatID).collection(messagesCollection).orderBy("sent_time", descending: false).snapshots();
  }

  Future<void> addMessageToChat(String chatId, ChatMessage message) async {
    logger.e(message);
    await _db.collection(chatCollection).doc(chatId).collection(messagesCollection).add(message.toJson());
    logger.e(chatId);

  }

  Future<void> updateUserLastSeenTime(String uid) async {
    await _db.collection(userCollection).doc(uid).update({"last_active": DateTime.now().toUtc()});
  }

  Future<void> deleteChat(String chatID) async {
    await _db.collection(chatCollection).doc(chatID).delete();
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> data) async {
  try {
    DocumentReference chatRef = await _db.collection(chatCollection).add(data);
    logger.i('Chat created successfully: ${chatRef.id}');
    return chatRef;
  } catch (e) {
    logger.e('Error creating chat: $e');
    return null;
  }
}

  void getChats(String userId) async {
    Stream<QuerySnapshot> chatStream = getChatsForUser(userId);
    chatStream.listen((snapshot) async {
      List<Chat> chats = await Future.wait(
        snapshot.docs.map((doc) async {
          Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;
          List<ChatUser> members = [];

          for (var uid in chatData["members"]) {
            DocumentSnapshot<Object?>? userSnapshot = await getUser(uid);

            if (userSnapshot != null && userSnapshot.exists) {
              Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
              userData["uid"] = userSnapshot.id;
              members.add(ChatUser.fromJSON(userData));
            } else {
              logger.e("User document with uid: $uid not found."); // Log user not found
            }
          }

          List<ChatMessage> messages = [];
          QuerySnapshot lastMessage = await getLastMessageForChat(doc.id);

          if (lastMessage.docs.isNotEmpty) {
            Map<String, dynamic> messageData = lastMessage.docs.first.data() as Map<String, dynamic>;
            messages.add(ChatMessage.fromJSON(messageData));
          }

          return Chat(
            uid: doc.id,
            currentUserUid: userId,
            members: members,
            messages: messages,
            activity: chatData["is_activity"],
            group: chatData["is_group"],
          );
        }),
      );

      logger.i('Fetched chats: $chats'); // Log the fetched chats
    }, onError: (error) {
      logger.e("Error fetching chats: $error"); // Log any error fetching chats
    });
  }
}