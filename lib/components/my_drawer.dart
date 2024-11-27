import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';

import '../pages/secondary/profile_page.dart';
import '../pages/secondary/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: authService.fetchCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching user data"));
          }

          final userData = snapshot.data;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // Profile information in DrawerHeader
                  DrawerHeader(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              userData?['profileImage'] ??
                                  'https://via.placeholder.com/150',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userData?['name'] ?? 'User Name',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // home list title
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: ListTile(
                      title: Text("H O M E"),
                      leading: Icon(Icons.home),
                      onTap: () {
                        // pop the drawer
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // settings list title
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: ListTile(
                      title: Text("S E T T I N G S"),
                      leading: Icon(Icons.settings),
                      onTap: () {
                        // pop the drawer
                        Navigator.pop(context);

                        // navigate to settings page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // logout list title
              Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 25),
                child: ListTile(
                  title: Text("L O G O U T"),
                  leading: Icon(Icons.logout),
                  onTap: logout,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
