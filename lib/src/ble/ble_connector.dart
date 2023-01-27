import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class BleConnector extends StatefulStream<BleConnectionState> {
  BleConnector({required this.deviceId});

  final String deviceId;
  BleConnectionState _state = BleConnectionState.disconnected;
  late StreamSubscription<ConnectionStateUpdate> _connection;

  @override
  BleConnectionState get state => _state;

  void _updateState(ConnectionStateUpdate update) {
    final newState = update.connectionState == DeviceConnectionState.connected
        ? BleConnectionState.connected
        : BleConnectionState.disconnected;
    _notifyIfChanged(newState);
  }

  void _notifyIfChanged(BleConnectionState newState) {
    if (newState != _state) {
      _state = newState;
      addStateToStream(state);
    }
  }

  Future<void> findAndConnect() async {
    _connection = ble
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: [serviceUuid],
            prescanDuration: const Duration(seconds: 10))
        .listen(
          _updateState,
          onError: (Object e) {},
        );
  }

  Future<void> connect() async {
    _connection = ble.connectToDevice(id: deviceId).listen(
          _updateState,
          onError: (Object e) {},
        );
  }

  Future<void> disconnect() async {
    try {
      await _connection.cancel();
    } catch (e) {
      // TODO: handle exception
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _notifyIfChanged(BleConnectionState.disconnected);
    }
  }
}

enum BleConnectionState { connected, disconnected }
