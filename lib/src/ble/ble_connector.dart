import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';

class BleConnector {
  final _stateStreamController = StreamController<ConnectionStateUpdate>();
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Stream<ConnectionStateUpdate> get stateStream =>
      _stateStreamController.stream;

  Future<void> findAndConnect(String deviceId, List<Uuid> withServices) async {
    _connection = ble
        .connectToAdvertisingDevice(
            id: deviceId,
            withServices: withServices,
            prescanDuration: const Duration(seconds: 10))
        .listen(
          (update) => _stateStreamController.add(update),
          onError: (Object e) {},
        );
  }

  Future<void> connect(String deviceId) async {
    _connection = ble.connectToDevice(id: deviceId).listen(
          (update) => _stateStreamController.add(update),
          onError: (Object e) {},
        );
  }

  Future<void> disconnect(String deviceId) async {
    try {
      await _connection.cancel();
    } on Exception catch (e, _) {
      // TODO: handle exception
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _stateStreamController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}

final bleConnector = BleConnector();
