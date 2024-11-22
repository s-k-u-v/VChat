import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_page_provider.dart';
import '../providers/chats_page_provider.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../models/chat.dart';
import '../providers/authentication_provider.dart';
import '../pages/chat_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return ChangeNotifierProvider<ChatsPageProvider>(
      create: (_) => ChatsPageProvider(authProvider),
      child: Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: Consumer<ChatsPageProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              itemCount: provider.chats.length,
              itemBuilder: (context, index) {
                Chat chat = provider.chats[index];
                return CustomListViewTile(
                  height: 70, // Correctly using named arguments
                  title: chat.title(),
                  subtitle: chat.messages.isNotEmpty ? chat.messages.first.content : 'No messages yet',
                  imagePath: chat.imageURL(),
                  isActive: chat.activity,
                  isSelected: false,
                  onTap: () {
                    // Navigate to ChatPage with provider
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider<ChatPageProvider>(
                          create: (_) => ChatPageProvider(chat.uid, authProvider), // Pass chat ID and auth provider
                          child: ChatPage(chat: chat),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}