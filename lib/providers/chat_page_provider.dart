import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vchat/models/chat_message.dart' as chatMessage;
import 'package:logger/logger.dart';
import 'package:vchat/providers/authentication_provider.dart';

import '../services/database_service.dart';

final Logger logger = Logger();

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  final String _chatId;
  List<chatMessage.ChatMessage> messages = []; // List of ChatMessage
  late StreamSubscription _messagesStream;

  ChatPageProvider(this._chatId, AuthenticationProvider authProvider) {
    _db = GetIt.instance.get<DatabaseService>();
    listenToMessages();
  }

  @override
  void dispose() {
    _messagesStream.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen((snapshot) {
        messages = snapshot.docs.map((doc) {
          Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;
          return chatMessage.ChatMessage.fromJSON(messageData); // Using prefixed import
        }).toList();
        
        notifyListeners(); // Notify listeners about the updates
      });
    } catch (e) {
      logger.e("Error getting messages: $e"); // Log the error
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.isNotEmpty) {
      final messageToSend = chatMessage.ChatMessage(
        content: content,
        type: chatMessage.MessageType.text, // Using prefixed import
        senderID: "currentUserID", // Replace with the actual user ID
        sentTime: DateTime.now(),
      );

      try {
        await _db.addMessageToChat(_chatId, messageToSend);
        logger.i("Message sent successfully!");
      } catch (e) {
        logger.e("Error sending message: $e"); // Log the error
      }
    } else {
      logger.i("Cannot send an empty message."); // Log empty message attempt
    }
  }

}