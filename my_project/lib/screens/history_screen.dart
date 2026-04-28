import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/history_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія подій'),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              return Row(
                children: [
                  Text(
                    state.useFirestore ? 'Firebase' : 'MockAPI',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Switch(
                    value: state.useFirestore,
                    activeColor: Colors.orange,
                    onChanged: (bool value) {
                      context.read<HistoryBloc>().add(
                        ToggleDataSourceEvent(value),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
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
                    leading: CircleAvatar(
                      backgroundColor: state.useFirestore
                          ? Colors.orange
                          : Colors.teal,
                      child: Icon(
                        state.useFirestore
                            ? Icons.local_fire_department
                            : Icons.history,
                        color: Colors.white,
                      ),
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
