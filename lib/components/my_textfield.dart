import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final Icon? prefixIcon;
  final IconButton? suffix;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator; // Add the validator parameter

  const MyTextField({
    super.key,
    this.focusNode,
    this.validator,
    this.prefixIcon,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        validator: validator, // Assign the validator to the TextFormField
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          suffix: suffix,
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
