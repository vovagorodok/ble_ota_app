import 'dart:async';

import 'package:universal_ble/universal_ble.dart' as backend;
import 'package:ble_ota_app/src/ble/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/universal_ble_mtu.dart';
import 'package:ble_ota_app/src/ble/universal_ble_characteristic.dart';

class UniversalBleConnector extends BaseBleConnector {
  UniversalBleConnector({required this.deviceId, required this.serviceIds}) {
    backend.UniversalBle.onConnectionChange =
        (String deviceId, bool isConnected) {
      if (deviceId != this.deviceId) return;
      if (isConnected) return;
      _updateConnectorStatus(BleConnectorStatus.disconnected);
    };
  }

  final String deviceId;
  final List<String> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    if (!await backend.UniversalBle.connect(deviceId)) return;
    await backend.UniversalBle.discoverServices(deviceId);
    _updateConnectorStatus(BleConnectorStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    await backend.UniversalBle.disconnect(deviceId);
    _updateConnectorStatus(BleConnectorStatus.disconnected);
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 2)}) async {
    await Future.delayed(duration);
  }

  @override
  Future<List<String>> discoverServices() async {
    return (await backend.UniversalBle.discoverServices(deviceId))
        .map((service) => service.uuid)
        .toList();
  }

  @override
  BleMtu createMtu() {
    return UniversalBleMtu(deviceId: deviceId);
  }

  @override
  BleCharacteristic createCharacteristic(
      String serviceId, String characteristicId) {
    return UniversalBleCharacteristic(
        deviceId: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId);
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    if (_state == status) return;
    _state = status;
    notifyState(_state);
  }
}
