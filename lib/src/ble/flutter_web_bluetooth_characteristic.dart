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
  late StreamSubscription _subscription;

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
  void subscribe({required void Function(List<int>) onData}) {
    subscribeAsync(onData: onData);
  }

  @override
  void unsubscribe() {
    unsubscribeAsync();
  }

  @override
  void dispose() {
    unsubscribe();
  }

  Future<void> subscribeAsync(
      {required void Function(List<int>) onData}) async {
    final characteristic = await _getCharacteristic();
    await characteristic.startNotifications();
    _subscription =
        characteristic.value.listen((data) => onData(data.buffer.asInt8List()));
  }

  Future<void> unsubscribeAsync() async {
    final characteristic = await _getCharacteristic();
    await characteristic.stopNotifications();
    _subscription.cancel();
  }

  Future<BluetoothCharacteristic> _getCharacteristic() async {
    final services = await device.discoverServices();
    final service = services.firstWhere((service) => service.uuid == serviceId);
    final characteristic = await service.getCharacteristic(characteristicId);
    return characteristic;
  }
}
