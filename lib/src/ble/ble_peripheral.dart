import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_connector.dart';

// TODO: Implement or remove
abstract class BlePeripheral {
  String get id;
  String get name;
  int get rssi;
  Future<BleConnector> createConnector();
}
