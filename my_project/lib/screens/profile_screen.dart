import 'package:flutter/material.dart';
import '../widgets/custom_ui.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мій Профіль',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.teal, width: 3),
                  ),
                  child: const Icon(Icons.person, size: 60, color: Colors.teal),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ВЛАСНИК НАЙКРАЩОГО У СВІТІ СМІТНИКА',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Панда Влад',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'panda@lpnu.ua',
                  style: TextStyle(fontSize: 16, color: Colors.teal),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 40),
                SmartButton(
                  text: 'ВИЙТИ З АКАУНТУ',
                  icon: Icons.logout,
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
