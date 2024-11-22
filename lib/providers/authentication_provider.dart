import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser userInfo;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _databaseService.updateUserLastSeenTime(user.uid);
        _databaseService.getUser(user.uid).then((snapshot) {
          if (snapshot!.exists) {
            Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
            userInfo = ChatUser.fromJSON({
              "uid": user.uid,
              "name": userData["name"],
              "email": userData["email"],
              "last_active": userData["last_active"],
              "image": userData["image"],
            });
            _navigationService.navigateToRoute('/home');
          } else {
            logger.e("User document does not exist.");
          }
        });
      } else {
        _navigationService.navigateToRoute('/login');
      }
    });
  }

  Future<void> createUser(
    String uid, 
    String email, 
    String name, 
    String imageURL
  ) async {
    try {
      // Create user document in Firestore
      await _databaseService.createUser(uid, email, name, imageURL);
      logger.i('User created successfully: $uid');
    } catch (e) {
      logger.e('Error creating user: $e');
      rethrow;
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credentials.user?.uid;
    } catch (e) {
      logger.e('Registration error: $e');
      return null;
    }
  }

  Future<void> loginUsingEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
