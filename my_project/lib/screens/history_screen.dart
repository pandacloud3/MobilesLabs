import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Історія подій')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryError) {
            return Center(
              child: Text(
                'Помилка: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is HistoryLoaded) {
            if (state.events.isEmpty) {
              return const Center(child: Text('Історія порожня'));
            }
            return ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.history, color: Colors.white),
                    ),
                    title: Text(
                      event.eventName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Час: ${event.timestamp}'),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Немає даних'));
        },
      ),
    );
  }
}
