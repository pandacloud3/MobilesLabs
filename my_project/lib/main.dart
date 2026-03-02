import 'package:flutter/material.dart';

void main() {
  runApp(const MagicApp());
}

class MagicApp extends StatelessWidget {
  const MagicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hogwarts Defender',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MagicCounterScreen(),
    );
  }
}

class MagicCounterScreen extends StatefulWidget {
  const MagicCounterScreen({super.key});

  @override
  State<MagicCounterScreen> createState() => _MagicCounterScreenState();
}

class _MagicCounterScreenState extends State<MagicCounterScreen> {
  int _dementorCount = 0;
  String _statusMessage = 'Ліс поки що тихий...';
  Color _backgroundColor = Colors.white;

  final TextEditingController _controller = TextEditingController();

  void _processInput(String input) {
    setState(() {
      final text = input.trim();
      final lowerText = text.toLowerCase();

      if (lowerText == 'avada kedavra') {
        _statusMessage = 'Заборонене закляття';
      } else if (lowerText == 'wingardium leviosa') {
        _statusMessage = 'Дементори левітують у повітрі. Ви виграли час!';
        _backgroundColor = Colors.purple.shade200;
      } else if (lowerText == 'expecto patronum') {
        _dementorCount = 0;
        _statusMessage = 'Ви вбили всіх дементорів';
        _backgroundColor = Colors.green.shade200;
      } else if (lowerText == 'expelliarmus') {
        if (_dementorCount > 0) {
          _dementorCount -= 1;
        }
        _statusMessage = 'Вбито одного дементора';
        _backgroundColor = Colors.red.shade200;
      } else {
        final int? value = int.tryParse(text);

        if (value != null) {
          _dementorCount += value;
          _statusMessage = '$value дементор(ів) вилетіли з чорного лісу!';
          _backgroundColor = Colors.blueGrey.shade100;
        } else if (text.isNotEmpty) {
          _statusMessage =
              'Неправильне число або заклинання. Вашу душу їдять дементори!';
          _backgroundColor = Colors.grey.shade400;
        }
      }
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Лабораторна 1: Захист Гоґвортсу'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Кількість живих дементорів:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$_dementorCount',
              style: const TextStyle(fontSize: 60, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Скільки вилізло дементорів? Застосуйте заклинання!',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _processInput(_controller.text),
                ),
              ),
              onSubmitted: _processInput,
            ),
          ],
        ),
      ),
    );
  }
}
