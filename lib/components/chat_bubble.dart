import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vchat/services/chat/chat_service.dart';

import '../models/file_viewer.dart';
import '../themes/theme_provide.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messadeId;
  final String userId;
  final String? fileUrl;

  const ChatBubble({
    super.key,
    this.fileUrl,
    required this.message,
    required this.isCurrentUser,
    required this.messadeId,
    required this.userId,
  });

  // show File
  void _showFile(BuildContext context) {
    // Navigate to a file viewer or implement file display logic here
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewer(fileUrl: fileUrl!),
      ),
    );
  }

  // show options
  void _showOptions(BuildContext context, String messadeId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // report message button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messadeId, userId);
                },
              ),

              // block user button
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),

              // cancel button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // delete message

  // report message
  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report this message?"),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // Report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message Reported")));
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  // block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // Report button
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("User Blocked!")));
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // bubble color == theme Change
    bool isDarkMode =
        Provider.of<ThemeProvide>(context, listen: false).isDarkMode;

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // show options
          _showOptions(context, messadeId, userId);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 250, // Limit the bubble's width
        ),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? (isDarkMode
                  ? const Color.fromARGB(255, 68, 9, 123)
                  : const Color.fromARGB(255, 132, 53, 205))
              : (isDarkMode
                  ? const Color.fromARGB(255, 16, 119, 9)
                  : const Color.fromARGB(255, 64, 194, 55)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        child: Column(
          children: [
            Text(
              message,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            if (fileUrl != null) // Check if fileUrl is not null
              GestureDetector(
                onTap: () => _showFile(context), // Show file when tapped
                child: Text(
                  'View File',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
