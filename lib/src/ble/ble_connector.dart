import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class BleConnector extends StateStream<ConnectionStateUpdate> {
  BleConnector({required this.deviceId});

  final String deviceId;
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> findAndConnect() async {
    _connection = ble
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: [serviceUuid],
            prescanDuration: const Duration(seconds: 10))
        .listen(
          (update) => addStateToStream(update),
          onError: (Object e) {},
        );
  }

  Future<void> connect() async {
    _connection = ble.connectToDevice(id: deviceId).listen(
          (update) => addStateToStream(update),
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
      addStateToStream(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }
}
