import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';
import 'package:vchat/components/my_textfield.dart';
import '../../buttons/my_button.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();

    try {
      final userCredential = await authService.signInWithEmailPassword(
        emailController.text,
        pwdController.text,
      );

      if (userCredential == null) {
        // Show snackbar if no user account found
        showSnackBar(context, 'No user account, create account');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
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
        child: SingleChildScrollView(
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
                ),
                const SizedBox(height: 10),
                MyTextField(
                  prefixIcon: Icon(Icons.password_sharp),
                  hintText: "Password",
                  obscureText: true,
                  controller: pwdController,
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Login",
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      login(context); // Only login if validation passes
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
                    const SizedBox(width: 8),
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
      ),
    );
  }
}