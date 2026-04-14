import 'package:flutter/material.dart';

class UrbanTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;

  const UrbanTextField({
    required this.hint, super.key,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(width: 2),
          ),
        ),
      ),
    );
  }
}
