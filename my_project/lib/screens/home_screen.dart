import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/bin_cubit.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _getTrashColor(String level) {
    if (level == 'Empty') {
      return Colors.green;
    }
    if (level == 'Medium') {
      return Colors.orange;
    }
    if (level == 'Full') {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розумний смітник'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<BinCubit, BinState>(
        builder: (context, state) {
          final tColor = _getTrashColor(state.trashLevel);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: state.isConnected
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.isConnected ? 'Підключено' : 'Відключено',
                      style: TextStyle(
                        color: state.isConnected
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Icon(
                    state.lidStatus == 'Opened'
                        ? Icons.delete_outline
                        : Icons.delete,
                    size: 120,
                    color: tColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.trashLevel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: tColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Кришка: ${state.lidStatus == 'Opened' ? 'ВІДКРИТА' : 'ЗАКРИТА'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: SwitchListTile(
                      title: const Text(
                        'Блокування кришки',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: state.isLidLocked,
                      activeColor: Colors.red,
                      secondary: Icon(
                        state.isLidLocked
                            ? Icons.block
                            : Icons.check_circle_outline,
                        color: state.isLidLocked ? Colors.red : Colors.green,
                      ),
                      onChanged: (bool value) {
                        context.read<BinCubit>().toggleLidLock(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
