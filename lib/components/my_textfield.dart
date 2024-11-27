import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final Icon? prefixIcon;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator; // Add the validator parameter

  const MyTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.validator, // Include the validator in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        validator: validator, // Assign the validator to the TextFormField
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}