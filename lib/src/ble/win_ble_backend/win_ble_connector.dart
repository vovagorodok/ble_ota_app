import 'dart:async';

import 'package:win_ble/win_ble.dart' as backend;
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_mtu.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_characteristic.dart';

class WinBleConnector extends BaseBleConnector {
  WinBleConnector({required this.deviceId, required this.serviceIds}) {
    backend.WinBle.connectionStreamOf(deviceId).listen((isConnected) {
      _updateConnectorStatus(isConnected
          ? BleConnectorStatus.connected
          : BleConnectorStatus.disconnected);
    });
  }

  final String deviceId;
  final List<String> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    await backend.WinBle.connect(deviceId);
  }

  @override
  Future<void> disconnect() async {
    await backend.WinBle.disconnect(deviceId);
  }

  @override
  Future<void> connectToKnownDevice(
      {Duration duration = const Duration(seconds: 2)}) async {
    throw UnsupportedError;
  }

  @override
  bool get isConnectToKnownDeviceSupported => false;

  @override
  Future<List<String>> discoverServices() async {
    return await backend.WinBle.discoverServices(deviceId);
  }

  @override
  BleMtu createMtu() {
    return WinBleMtu(deviceId: deviceId);
  }

  @override
  BleCharacteristic createCharacteristic(
      {required String serviceId, required String characteristicId}) {
    return WinBleCharacteristic(
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
