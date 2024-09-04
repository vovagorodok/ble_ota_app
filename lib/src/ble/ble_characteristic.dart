import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleCharacteristic {
  BleCharacteristic(
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

  Future<List<int>> read() async {
    return await backend.readCharacteristic(_characteristic);
  }

  Future<void> write(List<int> data) async {
    await backend.writeCharacteristicWithResponse(_characteristic, value: data);
  }

  Future<void> writeWithoutResponse(List<int> data) async {
    await backend.writeCharacteristicWithoutResponse(_characteristic,
        value: data);
  }

  void subscribe({required void Function(List<int>) onData}) {
    _subscription =
        backend.subscribeToCharacteristic(_characteristic).listen((event) {
      onData(event);
    });
  }

  void unsubscribe() {
    _subscription.cancel();
  }

  void dispose() {
    unsubscribe();
  }
}
