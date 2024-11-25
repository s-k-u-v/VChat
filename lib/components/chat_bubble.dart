import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provide.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    // bubble color == theme Change
    bool isDarkMode = Provider.of<ThemeProvide>(context, listen: false).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? (isDarkMode ? const Color.fromARGB(255, 2, 8, 175) : const Color.fromARGB(255, 7, 116, 206)) : (isDarkMode ? const Color.fromARGB(255, 16, 119, 9) : const Color.fromARGB(255, 64, 194, 55)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 25,
      ),
      child: Text(
        message,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
