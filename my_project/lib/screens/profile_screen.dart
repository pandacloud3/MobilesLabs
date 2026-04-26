import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/widgets/custom_ui.dart';
import 'package:my_project/cubits/profile_cubit.dart';
import 'package:my_project/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Видалення акаунту',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'Усі ваші дані будуть втрачені. Цю дію неможливо скасувати.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Скасувати',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Видалити',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<ProfileCubit>().deleteAccount();
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Вихід з акаунту'),
        content: const Text('Ви дійсно хочете вийти з поточного акаунту?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Скасувати',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Вийти',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<ProfileCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій профіль'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.teal.shade800,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && _nameController.text.isEmpty) {
              _nameController.text = state.user.name;
              _emailController.text = state.user.email;
              _passwordController.text = state.user.password;
            }
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Дані успішно оновлено!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is ProfileLoggedOut) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.teal, width: 2),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SmartTextField(
                          hint: 'Ім\'я користувача',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Введіть ім\'я';
                            if (value.contains(RegExp(r'[0-9]')))
                              return 'Ім\'я не може містити цифри';
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Електронна пошта',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SmartTextField(
                          hint: 'Пароль',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Введіть пароль';
                            if (value.length < 6) return 'Мінімум 6 символів';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SmartButton(
                          text: 'ЗБЕРЕГТИ ЗМІНИ',
                          icon: Icons.save_outlined,
                          onPressed: _updateProfile,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        SmartButton(
                          text: 'ВИЙТИ З АКАУНТУ',
                          icon: Icons.logout,
                          color: Colors.orange.shade400,
                          onPressed: _logout,
                        ),
                        const SizedBox(height: 16),
                        SmartButton(
                          text: 'ВИДАЛИТИ АКАУНТ',
                          icon: Icons.delete_forever,
                          color: Colors.redAccent,
                          onPressed: _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
