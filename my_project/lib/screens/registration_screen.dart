import 'package:flutter/material.dart';
import '../widgets/custom_ui.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal,
        title: const Text(
          'Реєстрація',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SmartTextField(
                    hint: 'Нікнейм',
                    icon: Icons.person_outline,
                  ),
                  const SmartTextField(
                    hint: 'Електронна пошта',
                    icon: Icons.email_outlined,
                  ),
                  const SmartTextField(
                    hint: 'Пароль',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SmartTextField(
                    hint: 'Повторіть пароль',
                    icon: Icons.lock_reset,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  SmartButton(
                    text: 'ЗАРЕЄСТРУВАТИСЯ',
                    icon: Icons.check_circle_outline,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    ),
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
