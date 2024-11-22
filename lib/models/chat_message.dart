import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

enum MessageType {
  text,
  image,
  unknown,
}

class ChatMessage {
  final String senderID;
  final MessageType type; // Ensure this is present
  final String content;
  final DateTime sentTime;

  ChatMessage({
    required this.content,
    required this.type, // Ensure this is required
    required this.senderID,
    required this.sentTime,
  });

  Map<String, dynamic> toJson() {
    logger.e(content);
    return {
      "content": content,
      "type": type.toString().split('.').last, // Convert enum to string
      "sender_id": senderID,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    logger.i(json);
    return ChatMessage(
      content: json["content"],
      type: MessageType.values.firstWhere((e) => e.toString() == 'MessageType.${json["type"]}'),
      senderID: json["sender_id"],
      sentTime: (json["sent_time"] as Timestamp).toDate(),
    );
  }
}

// ChatService class to handle Firestore operations
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createChat(String chatId, List<String> members) async {
    final docRef = _db.collection('Chats').doc(chatId);

    try {
      await docRef.set({
        'members': members,
        'created_at': FieldValue.serverTimestamp(),
      });
      logger.i("Chat document created successfully with ID: $chatId");
    } catch (e) {
      logger.e("Error creating chat document: $e");
    }
  }

  Future<void> fetchChat(String chatId) async {
    final docRef = _db.collection('Chats').doc(chatId);

    logger.i("Attempting to access chat with ID: $chatId");

    try {
      DocumentSnapshot chatDoc = await docRef.get();

      if (chatDoc.exists) {
        logger.i("Chat document found: ${chatDoc.data()}");
        // Handle chat data logic here...
      } else {
        logger.i("Chat document does not exist.");
        // Provide feedback to the user
      }
    } catch (e) {
      logger.e("Error fetching chat document: $e");
    }
  }
}

// Example Flutter widget to demonstrate usage
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _chatIdController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final ChatService _chatService = ChatService();

  void _createChat() {
    String chatId = _chatIdController.text.trim();
    List<String> members = _membersController.text.split(',').map((s) => s.trim()).toList();

    if (chatId.isNotEmpty && members.isNotEmpty) {
      _chatService.createChat(chatId, members);
    } else {
      logger.i("Please provide a valid chat ID and members.");
    }
  }

  void _fetchChat() {
    String chatId = _chatIdController.text.trim();

    if (chatId.isNotEmpty) {
      _chatService.fetchChat(chatId);
    } else {
      logger.i("Please provide a valid chat ID.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _chatIdController,
              decoration: InputDecoration(labelText: "Chat ID"),
            ),
            TextField(
              controller: _membersController,
              decoration: InputDecoration(labelText: "Members (comma separated)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createChat,
              child: Text("Create Chat"),
            ),
            ElevatedButton(
              onPressed: _fetchChat,
              child: Text("Fetch Chat"),
            ),
          ],
        ),
      ),
    );
  }
}


/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

enum MessageType {
  text,
  image,
  unknown,
}

class ChatMessage {
  final String senderID;
  final MessageType type;
  final String content;
  final DateTime sentTime;

  ChatMessage({
    required this.content,
    required this.type,
    required this.senderID,
    required this.sentTime,
  });

  Map<String, dynamic> toJson() {
    logger.e(content);
    return {
      "content": content,
      "type": type.toString().split('.').last, // Convert enum to string
      "sender_id": senderID,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    logger.i(json);
    return ChatMessage(
      content: json["content"],
      type: MessageType.values.firstWhere((e) => e.toString() == 'MessageType.${json["type"]}'),
      senderID: json["sender_id"],
      sentTime: (json["sent_time"] as Timestamp).toDate(),
    );
  }
} */