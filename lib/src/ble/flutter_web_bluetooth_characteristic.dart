import 'dart:async';
import 'dart:typed_data';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class FlutterWebBluetoothCharacteristic extends BleCharacteristic {
  FlutterWebBluetoothCharacteristic(
      {required this.device,
      required this.serviceId,
      required this.characteristicId});

  final BluetoothDevice device;
  final String serviceId;
  final String characteristicId;
  StreamSubscription? _subscription;

  @override
  Future<List<int>> read() async {
    final characteristic = await _getCharacteristic();
    return (await characteristic.readValue()).buffer.asInt8List();
  }

  @override
  Future<void> write(List<int> data) async {
    final characteristic = await _getCharacteristic();
    await characteristic.writeValueWithResponse(Uint8List.fromList(data));
  }

  @override
  Future<void> writeWithoutResponse(List<int> data) async {
    final characteristic = await _getCharacteristic();
    await characteristic.writeValueWithoutResponse(Uint8List.fromList(data));
  }

  @override
  Future<void> startNotifications() async {
    final characteristic = await _getCharacteristic();
    await characteristic.startNotifications();
    _subscription = characteristic.value
        .listen((data) => notifyData(data.buffer.asInt8List()));
  }

  @override
  Future<void> stopNotifications() async {
    final characteristic = await _getCharacteristic();
    await characteristic.stopNotifications();
    await _subscription?.cancel();
  }

  Future<BluetoothCharacteristic> _getCharacteristic() async {
    final services = await device.discoverServices();
    final service = services.firstWhere((service) => service.uuid == serviceId);
    final characteristic = await service.getCharacteristic(characteristicId);
    return characteristic;
  }
}
