import 'dart:async';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_mtu.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_characteristic.dart';

class FlutterWebBluetoothConnector extends BaseBleConnector {
  FlutterWebBluetoothConnector({required this.device}) {
    device.connected.listen(_updateConnected);
  }

  final BluetoothDevice device;
  BleConnectorStatus _status = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _status;

  @override
  Future<void> connect() async {
    _updateConnectorStatus(BleConnectorStatus.connecting);
    await device.connect();
  }

  @override
  Future<void> disconnect() async {
    if (_status == BleConnectorStatus.connected) {
      device.disconnect();
    }
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 2)}) async {
    _updateConnectorStatus(BleConnectorStatus.connecting);
    await Future.delayed(duration);
    await connect();
  }

  @override
  Future<List<String>> discoverServices() async {
    return (await device.discoverServices())
        .map((service) => service.uuid)
        .toList();
  }

  @override
  BleMtu createMtu() {
    return FlutterWebBluetoothMtu();
  }

  @override
  BleCharacteristic createCharacteristic(
      String serviceId, String characteristicId) {
    return FlutterWebBluetoothCharacteristic(
        device: device,
        serviceId: serviceId,
        characteristicId: characteristicId);
  }

  void _updateConnected(bool connected) {
    _updateConnectorStatus(connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected);
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    if (_status == status) return;
    _status = status;
    notifyState(_status);
  }
}
