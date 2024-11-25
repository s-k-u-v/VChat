import 'package:flutter/material.dart';
import 'package:vchat/services/auth/auth_service.dart';
import '../buttons/my_button.dart';
import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) {
    final auth = AuthService();
    if (pwdController.text == confirmPwdController.text) {
      try {
        auth.signUpWithEmailPassword(
          nameController.text,
          emailController.text,
          pwdController.text,
        );
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception();
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    String pattern = r".{1,}";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
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
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    } else if (pwdController.text != confirmPwdController.text) {
      return "Password dosen't match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // Add a global key for the form

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey, // Assign the key to the Form widget
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_alt_sharp,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's create an account for you",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    prefixIcon: Icon(Icons.person_4_sharp),
                    hintText: "Name",
                    obscureText: false,
                    controller: nameController,
                    validator: validateName, // Use the validator
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    prefixIcon: Icon(Icons.mail_sharp),
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                    validator: validateEmail, // Use the validator
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    prefixIcon: Icon(Icons.password_sharp),
                    hintText: "Password",
                    obscureText: true,
                    controller: pwdController,
                    validator: validatePassword, // Use the validator
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    prefixIcon: Icon(Icons.password_sharp),
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPwdController,
                    validator: validateConfirmPassword, // Use the validator
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    text: "Register",
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        register(context); // Only register if validation passes
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account??",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      GestureDetector(
                        onTap: onTap,
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
      ),
    );
  }
}