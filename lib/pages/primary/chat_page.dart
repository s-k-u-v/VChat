import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vchat/components/chat_bubble.dart';
import 'package:vchat/components/my_textfield.dart';
import 'package:vchat/services/auth/auth_service.dart';
import '../../services/chat/chat_service.dart';
import '../../themes/theme_provide.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController messageController = TextEditingController();

  // chat & auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // add lisitener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 400),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 400),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // scroll controller
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (messageController.text.isNotEmpty) {
      // send the message
      await chatService.sendMessage(widget.receiverID, messageController.text,
          file: null);

      // clear text controller
      messageController.clear();
    }
    scrollDown();
  }

  /* // Navigate to the profile page
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfilePage(userId: widget.receiverID), // Pass the receiver's ID
      ),
    );
  } */

  Future<void> selectFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await chatService.sendMessage(widget.receiverID, '',
          file: File(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.receiverName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
            child: buildMessageList(),
          ),

          // user input
          buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget buildMessageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        // Automatically scroll down when new messages come in
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData) {
            scrollDown();
          }
        });

        // return list view
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => buildUserListItem(doc)).toList(),
        );
      },
    );
  }

  Widget buildUserListItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // bubble color == theme Change
    bool isDarkMode =
        Provider.of<ThemeProvide>(context, listen: false).isDarkMode;

    final DateTime time = (data['timestamp'] as Timestamp).toDate();

    // is current user
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    // align message [ right -> current user ] others left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (data['message'] != '')
                ChatBubble(
                  message: data["message"],
                  isCurrentUser:
                      data['senderID'] == authService.getCurrentUser()!.uid,
                  messadeId: doc.id,
                  userId: data['senderID'],
                ),
              // Display image if exists
              if (data['fileUrl'] != null && data['fileUrl'].isNotEmpty)
                Container(
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
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 25,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['fileUrl'],
                          fit: BoxFit.cover,
                          width: 250,
                          height: 250,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.only(right: 2, left: 2),
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 25,
                ),
                child: Text(
                  DateFormat('h:mm a')
                      .format(time.toLocal()), // Format the timestamp
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // build message input
  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4, left: 8, top: 8),
      //padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
            child: MyTextField(
              hintText: "Type a message",
              obscureText: false,
              controller: messageController,
              focusNode: myFocusNode,
            ),
          ),

          // attach file button
          IconButton(
            icon: Icon(Icons.attach_file_sharp),
            onPressed: selectFile,
          ),

          // send button
          IconButton(
            icon: Icon(Icons.send_rounded),
            onPressed: sendMessage,
          )
        ],
      ),
    );
  }
}
