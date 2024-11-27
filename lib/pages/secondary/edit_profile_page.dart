import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({super.key});

  @override
  ProfileEditorPageState createState() => ProfileEditorPageState();
}

class ProfileEditorPageState extends State<ProfileEditorPage> {
  final AuthService _authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String? profileImageUrl; // To hold the profile image path

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() async {
    final userData = await _authService.fetchCurrentUserData();
    if (userData != null) {
      nameController.text = userData['name'] ?? '';
      bioController.text = userData['bio'] ?? ''; // Load current bio if available
      profileImageUrl = userData['profileImage']; // Load current profile image
    }
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImageUrl = pickedFile.path; // Update the profile image path
      });
    }
  }

  void _saveChanges() async {
    String newName = nameController.text;
    String newBio = bioController.text;

    if (newName.isNotEmpty) {
      // Update the user's name in Firestore
      await _authService.updateUserName(newName);
    }

    if (newBio.isNotEmpty) {
      // Update the user's bio in Firestore
      await _authService.updateUserBio(newBio);
    }

    if (profileImageUrl != null) {
      // If a new image is selected, update the profile image
      await _authService.updateProfileImage();
    }

    Navigator.pop(context); // Go back after saving changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: selectImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: profileImageUrl != null
                    ? ClipOval(
                        child: Image.file(
                          File(profileImageUrl!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.person_add, size: 50, color: Colors.grey[700]), // Default icon
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bioController,
              maxLength: 250, // Limit to 250 characters
              maxLines: 3, // Allow multiple lines
              decoration: const InputDecoration(
                labelText: "Bio (max 50 words)",
                hintText: "Write a short bio about yourself...",
              ),
            ),
            // Display word count
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "${bioController.text.split(' ').length} / 50 words",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}