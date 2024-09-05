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
      _updateConnectorStatus(BleConnectorStatus.disconnected);
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
    _updateConnectorStatus(_convertToConnecorStatus(update.connectionState));
  }

  void _updateConnectorStatus(BleConnectorStatus state) {
    _state = state;
    addStateToStream(_state);
  }

  static BleConnectorStatus _convertToConnecorStatus(
      DeviceConnectionState status) {
    switch (status) {
      case DeviceConnectionState.connecting:
        return BleConnectorStatus.connecting;
      case DeviceConnectionState.connected:
        return BleConnectorStatus.connected;
      case DeviceConnectionState.disconnecting:
        return BleConnectorStatus.disconnecting;
      default:
        return BleConnectorStatus.disconnected;
    }
  }
}

enum BleConnectorStatus {
  connecting,
  connected,
  disconnecting,
  disconnected,
}
