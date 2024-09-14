import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';

class FlutterReactiveBleConnector extends BleConnector {
  FlutterReactiveBleConnector(
      {required this.backend,
      required this.deviceId,
      required this.serviceIds});

  final FlutterReactiveBle backend;
  final String deviceId;
  final List<Uuid> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;
  StreamSubscription? _connection;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    _connection = backend.connectToDevice(id: deviceId).listen(
          _updateState,
          onError: (Object e) {},
        );
  }

  @override
  Future<void> disconnect() async {
    try {
      await _connection?.cancel();
    } catch (_) {
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _updateConnectorStatus(BleConnectorStatus.disconnected);
    }
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 20)}) async {
    _updateConnectorStatus(BleConnectorStatus.scanning);
    _connection = backend
        .connectToAdvertisingDevice(
            id: deviceId, withServices: serviceIds, prescanDuration: duration)
        .listen(
          _updateState,
          onDone: () => _updateConnectorStatus(BleConnectorStatus.disconnected),
          onError: (Object e) =>
              _updateConnectorStatus(BleConnectorStatus.disconnected),
        );
  }

  void _updateState(ConnectionStateUpdate update) {
    _updateConnectorStatus(_convertToConnecorStatus(update.connectionState));
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    _state = status;
    notifyState(_state);
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
