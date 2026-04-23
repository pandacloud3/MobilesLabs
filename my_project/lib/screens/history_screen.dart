import 'package:flutter/material.dart';
import '../domain/bin_event_model.dart';
import '../data/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<BinEvent>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Історія подій')),
      body: FutureBuilder<List<BinEvent>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Помилка: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final events = snapshot.data!;
            if (events.isEmpty) {
              return const Center(child: Text('Історія порожня'));
            }
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
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
