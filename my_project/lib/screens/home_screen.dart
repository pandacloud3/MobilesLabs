import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late MqttServerClient _mqttClient;

  bool _isConnected = false;
  String _trashLevel = 'Очікування...';
  String _lidStatus = 'Очікування...';

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _setupMqtt();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _mqttClient.disconnect();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineWarning('Ви увійшли в офлайн-режимі. Дані недоступні!');
      });
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _showOfflineWarning('Зв\'язок втрачено!');
      if (mounted) setState(() => _isConnected = false);
    } else {
      _setupMqtt();
    }
  }

  void _showOfflineWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _setupMqtt() async {
    String clientId = 'flutter_win_${DateTime.now().millisecondsSinceEpoch}';
    _mqttClient = MqttServerClient('broker.hivemq.com', clientId);
    _mqttClient.port = 1883;
    _mqttClient.logging(on: false);
    _mqttClient.keepAlivePeriod = 20;

    _mqttClient.onDisconnected = () {
      if (mounted) setState(() => _isConnected = false);
    };

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _mqttClient.connectionMessage = connMess;

    try {
      await _mqttClient.connect();
    } catch (e) {
      _mqttClient.disconnect();

      _mqttClient = MqttServerClient.withPort(
        'broker.hivemq.com',
        '${clientId}_sec',
        8883,
      );
      _mqttClient.secure = true;
      try {
        await _mqttClient.connect();
      } catch (e2) {
        return;
      }
    }

    if (_mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      if (mounted) setState(() => _isConnected = true);

      _mqttClient.subscribe('smart_bin/trash_level', MqttQos.atMostOnce);
      _mqttClient.subscribe('smart_bin/lid_status', MqttQos.atMostOnce);

      _mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        final topic = c[0].topic;

        if (mounted) {
          setState(() {
            if (topic == 'smart_bin/trash_level') {
              _trashLevel = payload;
            } else if (topic == 'smart_bin/lid_status') {
              _lidStatus = payload;
            }
          });
        }
      });
    }
  }

  Color _getTrashColor() {
    switch (_trashLevel) {
      case 'Empty':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Full':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTrashText() {
    switch (_trashLevel) {
      case 'Empty':
        return 'Порожній';
      case 'Medium':
        return 'Наполовину';
      case 'Full':
        return 'ПОВНИЙ!';
      default:
        return _trashLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розумний смітник'),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isConnected
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Підключено' : 'Відключено',
                      style: TextStyle(
                        color: _isConnected
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Icon(
                _lidStatus == 'Opened' ? Icons.delete_outline : Icons.delete,
                size: 120,
                color: _getTrashColor(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Рівень заповнення:',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                _getTrashText(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getTrashColor(),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _lidStatus == 'Opened' ? Icons.lock_open : Icons.lock,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Кришка: ${_lidStatus == 'Opened' ? 'ВІДКРИТА' : 'ЗАКРИТА'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
