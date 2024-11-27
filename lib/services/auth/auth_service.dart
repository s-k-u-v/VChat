import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  // Instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //get currrent user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection("Users").doc(currentUser.uid).update({
        'name': newName,
      });
    }
  }

  // Fetch every user's data
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection("Users").doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Fetch current user's data from Firestore
  Future<Map<String, dynamic>?> fetchCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection("Users").doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // User Bio
  Future<void> updateUserBio(String newBio) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection("Users").doc(currentUser.uid).update({
        'bio': newBio,
      });
    }
  }

  // sign in
  Future<UserCredential?> signInWithEmailPassword(String email, password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info if it dosen't already exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
        SetOptions(merge: true),
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return null; // Return null to indicate no user found
      }
      throw Exception(e.code);
    }
  }

  // sign up
  Future<UserCredential> signUpWithEmailPassword(String name, email, password,
      {String? profileImageUrl}) async {
    try {
      // create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info in a separate doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'name': name,
          'profileImage': profileImageUrl,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // Password is correct
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return false; // Wrong password
      }
      throw Exception(e.code);
    }
  }

  Future<void> updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // The local path of the image
      final filePath = pickedFile.path;

      // Create a reference to the location in Firebase Storage
      final storageRef = _storage.ref().child('profile_images/${getCurrentUser()!.uid}');

      // Upload the image to Firebase Storage
      final file = File(filePath);
      storageRef.putFile(file);

      // Get the download URL of the uploaded image
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new profile image URL
      await _firestore.collection("Users").doc(getCurrentUser()!.uid).update({
        'profileImage': downloadUrl,
      });
    }
  }
}
