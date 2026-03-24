import 'package:flutter/material.dart';
import '../widgets/custom_ui.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAutoModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'МІЙ СМІТНИК',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 0.27,
                        strokeWidth: 15,
                        color: Colors.teal.shade400,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const Column(
                      children: [
                        Text(
                          '27%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text('Заповнено', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Авто-відкриття',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('(Захист від домашніх тварин)'),
                        value: _isAutoModeEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _isAutoModeEnabled = value;
                          });
                        },
                        secondary: const Icon(
                          Icons.motion_photos_on,
                          color: Colors.teal,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SmartButton(
                              text: 'Відкрити',
                              icon: Icons.lock_open,
                              color: Colors.orange.shade400,
                              fontSize: 14,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SmartButton(
                              text: 'Закрити',
                              icon: Icons.lock,
                              color: Colors.blueGrey,
                              fontSize: 14,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SmartButton(
                        text: 'Відкалібрувати рівень',
                        icon: Icons.radar,
                        color: Colors.indigo.shade400,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
