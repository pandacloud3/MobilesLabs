import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class BinState {
  final bool isConnected;
  final String trashLevel;
  final String lidStatus;
  final bool isLidLocked;

  BinState({
    this.isConnected = false,
    this.trashLevel = 'Очікування...',
    this.lidStatus = 'Очікування...',
    this.isLidLocked = false,
  });

  BinState copyWith({
    bool? isConnected,
    String? trashLevel,
    String? lidStatus,
    bool? isLidLocked,
  }) {
    return BinState(
      isConnected: isConnected ?? this.isConnected,
      trashLevel: trashLevel ?? this.trashLevel,
      lidStatus: lidStatus ?? this.lidStatus,
      isLidLocked: isLidLocked ?? this.isLidLocked,
    );
  }
}

class BinCubit extends Cubit<BinState> {
  late MqttServerClient _mqttClient;

  BinCubit() : super(BinState()) {
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return;
    }

    String clientId = 'flutter_win_${DateTime.now().millisecondsSinceEpoch}';
    _mqttClient = MqttServerClient('broker.hivemq.com', clientId)
      ..port = 1883
      ..logging(on: false);

    _mqttClient.onDisconnected = () {
      if (!isClosed) emit(state.copyWith(isConnected: false));
    };

    _mqttClient.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    try {
      await _mqttClient.connect();
    } catch (e) {
      _mqttClient.disconnect();
      return;
    }

    if (_mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      if (!isClosed) emit(state.copyWith(isConnected: true));

      _mqttClient.subscribe('smart_bin/trash_level', MqttQos.atMostOnce);
      _mqttClient.subscribe('smart_bin/lid_status', MqttQos.atMostOnce);

      _mqttClient.updates!.listen((c) {
        final payload = MqttPublishPayload.bytesToStringAsString(
          (c![0].payload as MqttPublishMessage).payload.message,
        );
        if (c[0].topic == 'smart_bin/trash_level') {
          if (!isClosed) emit(state.copyWith(trashLevel: payload));
        } else if (c[0].topic == 'smart_bin/lid_status') {
          if (!isClosed) emit(state.copyWith(lidStatus: payload));
        }
      });
    }
  }

  void toggleLidLock(bool value) {
    if (!state.isConnected) return;
    emit(state.copyWith(isLidLocked: value));

    final builder = MqttClientPayloadBuilder()
      ..addString(value ? 'lock_on' : 'lock_off');
    _mqttClient.publishMessage(
      'smart_bin/command',
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  @override
  Future<void> close() {
    _mqttClient.disconnect();
    return super.close();
  }
}
