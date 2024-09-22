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
  Future<Uint8List> read() async {
    final characteristic = await _getCharacteristic();
    return (await characteristic.readValue()).buffer.asUint8List();
  }

  @override
  Future<void> write({required Uint8List data}) async {
    final characteristic = await _getCharacteristic();
    await characteristic.writeValueWithResponse(data);
  }

  @override
  Future<void> writeWithoutResponse({required Uint8List data}) async {
    final characteristic = await _getCharacteristic();
    await characteristic.writeValueWithoutResponse(data);
  }

  @override
  Future<void> startNotifications() async {
    final characteristic = await _getCharacteristic();
    await characteristic.startNotifications();
    _subscription = characteristic.value
        .listen((data) => notifyData(data.buffer.asUint8List()));
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
