import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class FlutterReactiveBleCharacteristic extends BleCharacteristic {
  FlutterReactiveBleCharacteristic(
      {required this.backend,
      required String deviceId,
      required Uuid serviceId,
      required Uuid characteristicId})
      : _characteristic = QualifiedCharacteristic(
            characteristicId: characteristicId,
            serviceId: serviceId,
            deviceId: deviceId);

  final FlutterReactiveBle backend;
  final QualifiedCharacteristic _characteristic;
  StreamSubscription? _subscription;

  @override
  Future<List<int>> read() async {
    return await backend.readCharacteristic(_characteristic);
  }

  @override
  Future<void> write(List<int> data) async {
    await backend.writeCharacteristicWithResponse(_characteristic, value: data);
  }

  @override
  Future<void> writeWithoutResponse(List<int> data) async {
    await backend.writeCharacteristicWithoutResponse(_characteristic,
        value: data);
  }

  @override
  Future<void> startNotifications() async {
    _subscription =
        backend.subscribeToCharacteristic(_characteristic).listen(notifyData);
  }

  @override
  Future<void> stopNotifications() async {
    await _subscription?.cancel();
  }
}
