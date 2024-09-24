import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/bluez_mtu.dart';
import 'package:ble_ota_app/src/ble/bluez_characteristic.dart';

class BlueZConnector extends BaseBleConnector {
  BlueZConnector({required this.device, required this.serviceIds});

  final BlueZDevice device;
  final List<String> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    _updateConnectorStatus(BleConnectorStatus.connecting);
    await device.connect();

    int attempts = 0;
    while (attempts < 100 && !device.connected) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    _updateConnectorStatus(device.connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected);
  }

  @override
  Future<void> disconnect() async {
    await device.disconnect();
    _updateConnectorStatus(BleConnectorStatus.disconnected);
  }

  @override
  Future<void> connectToKnownDevice(
      {Duration duration = const Duration(seconds: 2)}) async {
    await Future.delayed(duration);
  }

  @override
  Future<List<String>> discoverServices() async {
    return device.gattServices
        .map((service) => service.uuid.toString())
        .toList();
  }

  @override
  BleMtu createMtu() {
    return BlueZMtu(device: device);
  }

  @override
  BleCharacteristic createCharacteristic(
      {required String serviceId, required String characteristicId}) {
    return BlueZCharacteristic(
        device: device,
        serviceId: BlueZUUID.fromString(serviceId),
        characteristicId: BlueZUUID.fromString(characteristicId));
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    _state = status;
    notifyState(_state);
  }
}
