import 'package:ble_ota_app/src/ble/ble_connector.dart';

abstract class BlePeripheral {
  String get id;
  String get name;
  int get rssi; // TODO: Optional?
  BleConnector createConnector();
}
