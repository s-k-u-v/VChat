// users_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/users_page_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/rounded_button.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return ChangeNotifierProvider<UsersPageProvider>(
      create: (_) => UsersPageProvider(authProvider),
      child: Scaffold(
        appBar: AppBar(title: Text('Users')),
        body: Consumer<UsersPageProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TopBar(
                    'Users',
                    primaryAction: IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        authProvider.logout();
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.users?.length ?? 0,
                      itemBuilder: (context, index) {
                        final user = provider.users![index];
                        return CustomListViewTile(
                          height: 70,
                          title: user.name,
                          subtitle: user.lastDayActive(),
                          imagePath: user.imageURL,
                          isActive: user.wasRecentlyActive(),
                          isSelected: provider.selectedUsers.contains(user),
                          onTap: () {
                            provider.updateSelectedUsers(user);
                          },
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: provider.selectedUsers.isNotEmpty,
                    child: RoundedButton(
                      name: provider.selectedUsers.length == 1
                          ? "Chat With ${provider.selectedUsers.first.name}"
                          : "Create Group Chat",
                      height: 50,
                      width: double.infinity,
                      onPressed: () {
                        provider.createChat(context); // Pass the context here
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}