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
  late StreamSubscription _subscription;

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
  void subscribe({required void Function(List<int>) onData}) {
    _subscription =
        backend.subscribeToCharacteristic(_characteristic).listen((event) {
      onData(event);
    });
  }

  @override
  void unsubscribe() {
    _subscription.cancel();
  }

  @override
  void dispose() {
    unsubscribe();
  }
}
