import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';
import 'package:vchat/components/my_textfield.dart';
import '../buttons/my_button.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        emailController.text,
        pwdController.text,
      );
    } catch (e) {
      throw Exception(e);
    }
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

    /* // Check if the email exists in user data
    final authService = AuthService();
    if (authService.getCurrentUser() == null ||
        authService.getCurrentUser()!.email != value) {
      return 'Email not found. Please register.';
    } */
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

  Future<void> handleLogin(BuildContext context) async {
    final authService = AuthService();
    String email = emailController.text;
    String password = pwdController.text;

    // Verify password
    bool isPasswordValid = await authService.verifyPassword(email, password);
    if (!isPasswordValid) {
      showSnackBar(context, 'Password does not match for this email.');
      return;
    }

    // If validation passes, log in the user
    login(context);
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // Add a global key for the form

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Form(
          key: formKey, // Assign the key to the Form widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome back, you've been missed!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              MyTextField(
                prefixIcon: Icon(Icons.mail_sharp),
                hintText: "Email",
                obscureText: false,
                controller: emailController,
                validator: validateEmail, // Use the validator
              ),
              const SizedBox(height: 10),
              MyTextField(
                prefixIcon: Icon(Icons.password_sharp),
                hintText: "Password",
                obscureText: true,
                controller: pwdController,
                validator: validatePassword, // Use the validator
              ),
              const SizedBox(height: 25),
              MyButton(
                text: "Login",
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    handleLogin(context); // Only login if validation passes
                  }
                },
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member??",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Register now",
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
    );
  }
}
