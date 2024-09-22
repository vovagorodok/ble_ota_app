import 'dart:async';

import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

abstract class BleConnector extends StatefulNotifier<BleConnectorStatus> {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> connectToKnownDevice({Duration duration});
  Future<List<String>> discoverServices();

  BleMtu createMtu();
  BleCharacteristic createCharacteristic(
      {required String serviceId, required String characteristicId});
  BleSerial createSerial(
      {required String serviceId,
      required String rxCharacteristicId,
      required String txCharacteristicId});
}

enum BleConnectorStatus {
  connecting,
  connected,
  disconnecting,
  disconnected,
  scanning,
}
