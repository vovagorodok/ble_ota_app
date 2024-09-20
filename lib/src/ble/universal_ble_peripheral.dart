import 'package:universal_ble/universal_ble.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/universal_ble_connector.dart';

class UniversalBlePeripheral extends BlePeripheral {
  UniversalBlePeripheral({required this.device, required this.serviceIds});

  final BleDevice device;
  final List<String> serviceIds;

  @override
  String get id => device.deviceId;
  @override
  String? get name => device.name;
  @override
  int? get rssi => device.rssi;

  @override
  BleConnector createConnector() {
    return UniversalBleConnector(
      deviceId: device.deviceId,
      serviceIds: serviceIds,
    );
  }
}
