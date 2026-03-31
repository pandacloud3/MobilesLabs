import 'package:flutter/material.dart';
import '../widgets/custom_ui.dart';
import '../domain/user_model.dart';
import '../data/local_user_repository.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userRepository = LocalUserRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final success = await _userRepository.registerUser(newUser);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Реєстрація успішна!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Створити акаунт'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal.shade800,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 80,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 32),

                    SmartTextField(
                      hint: 'Ім\'я користувача',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Будь ласка, введіть ім\'я';
                        if (value.contains(RegExp(r'[0-9]')))
                          return 'Ім\'я не може містити цифри';
                        return null;
                      },
                    ),

                    SmartTextField(
                      hint: 'Електронна пошта',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Будь ласка, введіть пошту';
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Введіть коректну електронну пошту';
                        }
                        return null;
                      },
                    ),

                    SmartTextField(
                      hint: 'Пароль (мінімум 6 символів)',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Будь ласка, введіть пароль';
                        if (value.length < 6) return 'Пароль занадто короткий';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    SmartButton(
                      text: 'ЗАРЕЄСТРУВАТИСЯ',
                      icon: Icons.check_circle_outline,
                      onPressed: _registerUser,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
