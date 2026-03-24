import 'package:flutter/material.dart';
import '../widgets/custom_ui.dart';
import 'home_screen.dart';
import 'registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == 'panda' && password == '7777') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Невірна пошта або пароль!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_sweep_rounded,
                      size: 100,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Smart Trash Can',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'Твій розумний смітник',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  SmartTextField(
                    hint: 'Електронна пошта',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                  ),
                  SmartTextField(
                    hint: 'Пароль',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  const SizedBox(height: 24),
                  SmartButton(
                    text: 'УВІЙТИ',
                    icon: Icons.login,
                    onPressed: _checkLogin,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegistrationScreen(),
                      ),
                    ),
                    child: const Text(
                      'Ще немає акаунту? Зареєструватися',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
