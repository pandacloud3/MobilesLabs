import 'package:flutter/material.dart';

class UrbanButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const UrbanButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, letterSpacing: 2),
        ),
      ),
    );
  }
}
