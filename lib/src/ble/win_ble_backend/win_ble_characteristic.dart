import 'dart:async';
import 'dart:typed_data';

import 'package:win_ble/win_ble.dart' as backend;
import 'package:ble_ota_app/src/ble/ble_backend/ble_characteristic.dart';

class WinBleCharacteristic extends BleCharacteristic {
  WinBleCharacteristic(
      {required this.deviceId,
      required this.serviceId,
      required this.characteristicId}) {
    backend.WinBle.characteristicValueStreamOf(
            address: deviceId,
            serviceId: serviceId,
            characteristicId: characteristicId)
        .listen((value) {
      notifyData(value);
    });
  }

  final String deviceId;
  final String serviceId;
  final String characteristicId;

  @override
  Future<Uint8List> read() async {
    return Uint8List.fromList(await backend.WinBle.read(
        address: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId));
  }

  @override
  Future<void> write({required Uint8List data}) async {
    await backend.WinBle.write(
        address: deviceId,
        service: serviceId,
        characteristic: characteristicId,
        data: data,
        writeWithResponse: true);
  }

  @override
  Future<void> writeWithoutResponse({required Uint8List data}) async {
    await backend.WinBle.write(
        address: deviceId,
        service: serviceId,
        characteristic: characteristicId,
        data: data,
        writeWithResponse: false);
  }

  @override
  Future<void> startNotifications() async {
    await backend.WinBle.subscribeToCharacteristic(
        address: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId);
  }

  @override
  Future<void> stopNotifications() async {
    await backend.WinBle.unSubscribeFromCharacteristic(
        address: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId);
  }
}
