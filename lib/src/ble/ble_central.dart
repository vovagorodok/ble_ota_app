import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

abstract class BleCentral extends StatefulStream<BleCentralStatus> {
  BleScanner createScaner(List<String> serviceIds);
  BleConnector createConnector(String deviceId, List<String> serviceIds);
  BleMtu createMtu(String deviceId);
  BleCharacteristic createCharacteristic(
      String deviceId, String serviceId, String characteristicId);
  BleSerial createSerial(String deviceId, String serviceId,
      String rxCharacteristicId, String txCharacteristicId);
}

enum BleCentralStatus {
  // TODO: Add unsupportedBrowser
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready
}
