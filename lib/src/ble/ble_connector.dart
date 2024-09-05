import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

class BleConnector extends StatefulStream<BleConnectorStatus> {
  BleConnector(
      {required this.backend,
      required this.deviceId,
      required this.serviceIds});

  final FlutterReactiveBle backend;
  final String deviceId;
  final List<Uuid> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;
  late StreamSubscription<ConnectionStateUpdate> _connection;

  @override
  BleConnectorStatus get state => _state;

  Future<void> connect() async {
    _connection = backend.connectToDevice(id: deviceId).listen(
          _updateState,
          onError: (Object e) {},
        );
  }

  Future<void> disconnect() async {
    try {
      await _connection.cancel();
    } catch (_) {
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _notifyIfChanged(BleConnectorStatus.disconnected);
    }
  }

  Future<void> scanAndConnect() async {
    _connection = backend
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: serviceIds,
            prescanDuration: const Duration(seconds: 20))
        .listen(
          _updateState,
          onError: (Object e) {},
        );
  }

  void _updateState(ConnectionStateUpdate update) {
    final newState = update.connectionState == DeviceConnectionState.connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected;
    _notifyIfChanged(newState);
  }

  void _notifyIfChanged(BleConnectorStatus newState) {
    if (newState != _state) {
      _state = newState;
      addStateToStream(state);
    }
  }
}

enum BleConnectorStatus {
  connected,
  disconnected,
}
