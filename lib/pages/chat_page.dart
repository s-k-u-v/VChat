import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_page_provider.dart';
import '../models/chat.dart';
import '../widgets/custom_input_fields.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatPageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.title())),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final message = provider.messages[index];
                return ListTile(
                  title: Text(message.content),
                  textColor: Colors.red,
                  subtitle: Text(message.sentTime.toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _messageController,
                    onSaved: (value) {
                      provider.sendMessage(value);
                    },
                    regEx: r".{1,}",
                    hintText: "Type a message",
                    obscureText: false,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String messageContent = _messageController.text.trim();
                    logger.i(messageContent);
                    ChatPageProvider provider =
                        Provider.of<ChatPageProvider>(context, listen: false);
                    provider.sendMessage(
                        messageContent); // Call the method to send the message
                    logger.i(messageContent);
                    _messageController.clear(); // Clear the input field
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
