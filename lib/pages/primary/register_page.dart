import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';
import '../../buttons/my_button.dart';
import '../../components/my_textfield.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();

  String? profileImageUrl; // To hold the profile image URL

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImageUrl = pickedFile.path; // Update the profile image path
      });
    }
  }

  void register(BuildContext context) async {
    final auth = AuthService();
    if (pwdController.text == confirmPwdController.text) {
      try {
        await auth.signUpWithEmailPassword(
          nameController.text,
          emailController.text,
          pwdController.text,
          profileImageUrl: profileImageUrl,
        );

        // After successfully registering, update the profile image
        await auth.updateProfileImage();

        // Optionally, navigate to another page or show a success message
        Navigator.pop(context); // Go back after successful registration
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Passwords do not match");
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (pwdController.text != confirmPwdController.text) {
      return "Passwords don't match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                        : Icon(Icons.person_add, size: 50, color: Colors.grey[700]), // Placeholder image
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  prefixIcon: Icon(Icons.person_4_sharp),
                  hintText: "Name",
                  obscureText: false,
                  controller: nameController,
                  validator: validateName,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  prefixIcon: Icon(Icons.mail_sharp),
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                  validator: validateEmail,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  prefixIcon: Icon(Icons.password_sharp),
                  hintText: "Password",
                  obscureText: true,
                  controller: pwdController,
                  validator: validatePassword,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  prefixIcon: Icon(Icons.password_sharp),
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPwdController,
                  validator: validateConfirmPassword,
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Register",
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      register(context);
                    }
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account??",
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}