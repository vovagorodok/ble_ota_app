import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector({required FlutterReactiveBle ble}) : _ble = ble;

  final FlutterReactiveBle _ble;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    print('Start connecting to $deviceId');
    _connection = _ble.connectToDevice(id: deviceId).listen(
      (update) {
        print(
            'ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          print('Connecting to device $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId) async {
    try {
      print('disconnecting to device: $deviceId');
      await _connection.cancel();
    } on Exception catch (e, _) {
      print("Error disconnecting from a device: $e");
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
