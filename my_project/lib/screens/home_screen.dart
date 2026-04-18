import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connSub;
  late MqttServerClient _mqttClient;
  bool _isConnected = false, _isLidLocked = false;
  String _trashLevel = 'Очікування...', _lidStatus = 'Очікування...';

  @override
  void initState() {
    super.initState();
    _checkInitialConn();
    _connSub = Connectivity().onConnectivityChanged.listen(_updateConn);
    _setupMqtt();
  }

  @override
  void dispose() {
    _connSub.cancel();
    _mqttClient.disconnect();
    super.dispose();
  }

  Future<void> _checkInitialConn() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMsg('Ви в офлайн-режимі!');
      });
    }
  }

  void _updateConn(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _showMsg('Зв\'язок втрачено!');
      if (mounted) {
        setState(() => _isConnected = false);
      }
    } else {
      _setupMqtt();
    }
  }

  void _showMsg(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Future<void> _setupMqtt() async {
    String clientId = 'flutter_win_${DateTime.now().millisecondsSinceEpoch}';
    _mqttClient = MqttServerClient('broker.hivemq.com', clientId)
      ..port = 1883
      ..logging(on: false)
      ..keepAlivePeriod = 20;

    _mqttClient.onDisconnected = () {
      if (mounted) {
        setState(() => _isConnected = false);
      }
    };

    _mqttClient.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await _mqttClient.connect();
    } catch (e) {
      _mqttClient.disconnect();
      _mqttClient = MqttServerClient.withPort(
        'broker.hivemq.com',
        '${clientId}_sec',
        8883,
      )..secure = true;
      try {
        await _mqttClient.connect();
      } catch (e2) {
        return;
      }
    }

    if (_mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      if (mounted) {
        setState(() => _isConnected = true);
      }
      _mqttClient.subscribe('smart_bin/trash_level', MqttQos.atMostOnce);
      _mqttClient.subscribe('smart_bin/lid_status', MqttQos.atMostOnce);
      _mqttClient.updates!.listen((c) {
        final payload = MqttPublishPayload.bytesToStringAsString(
          (c![0].payload as MqttPublishMessage).payload.message,
        );
        if (mounted) {
          setState(() {
            if (c[0].topic == 'smart_bin/trash_level') {
              _trashLevel = payload;
            } else if (c[0].topic == 'smart_bin/lid_status') {
              _lidStatus = payload;
            }
          });
        }
      });
    }
  }

  void _toggleLidLock(bool value) {
    setState(() => _isLidLocked = value);
    if (!_isConnected) {
      _showMsg('Немає підключення до брокера!');
      return;
    }
    final builder = MqttClientPayloadBuilder()
      ..addString(_isLidLocked ? 'lock_on' : 'lock_off');
    _mqttClient.publishMessage(
      'smart_bin/command',
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  Color get _tColor {
    if (_trashLevel == 'Empty') return Colors.green;
    if (_trashLevel == 'Medium') return Colors.orange;
    if (_trashLevel == 'Full') return Colors.red;
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
      body: Center(
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
                  color: _isConnected
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isConnected ? 'Підключено' : 'Відключено',
                  style: TextStyle(
                    color: _isConnected
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Icon(
                _lidStatus == 'Opened' ? Icons.delete_outline : Icons.delete,
                size: 120,
                color: _tColor,
              ),
              const SizedBox(height: 20),
              Text(
                _trashLevel,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _tColor,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Кришка: ${_lidStatus == 'Opened' ? 'ВІДКРИТА' : 'ЗАКРИТА'}',
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
                  value: _isLidLocked,
                  secondary: Icon(
                    _isLidLocked ? Icons.block : Icons.check_circle_outline,
                    color: _isLidLocked ? Colors.red : Colors.green,
                  ),
                  onChanged: _toggleLidLock,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
