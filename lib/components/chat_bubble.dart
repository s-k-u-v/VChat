import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vchat/services/chat/chat_service.dart';

import '../themes/theme_provide.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messadeId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messadeId,
    required this.userId,
  });

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

  // report message
  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Report Message"),
              content:
                  const Text("Are you sure you want to report this message?"),
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
            ));
  }

  // block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Block User"),
              content:
                  const Text("Are you sure you want to block this user?"),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User Blocked!")));
                  },
                  child: const Text("Block"),
                ),
              ],
            ));
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
        decoration: BoxDecoration(
          color: isCurrentUser
              ? (isDarkMode
                  ? const Color.fromARGB(255, 2, 8, 175)
                  : const Color.fromARGB(255, 7, 116, 206))
              : (isDarkMode
                  ? const Color.fromARGB(255, 16, 119, 9)
                  : const Color.fromARGB(255, 64, 194, 55)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        child: Column(
          children: [
            Text(
              message,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
