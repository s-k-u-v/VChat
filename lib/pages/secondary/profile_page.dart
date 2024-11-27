import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';

import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.fetchCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error fetching user data"));
        }

        final userData = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text("PROFILE"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditorPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData?['profileImage'] ??
                      'https://via.placeholder.com/150'), // Use a placeholder image if the URL is null
                ),
                const SizedBox(height: 20),
                Text(
                  userData?['name'] ??
                      'User Name', // Display user name or default
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  userData?['email'] ??
                      'user@example.com', // Display user email or default
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  userData?['bio'] ?? 'No bio available', // Display user bio or default
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
