import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_connector.dart';

class BluetoothLowEnergyPeripheral extends BlePeripheral {
  BluetoothLowEnergyPeripheral(
      {required this.backend, required this.serviceIds, required this.device});

  final CentralManager backend;
  final List<UUID> serviceIds;
  final DiscoveredEventArgs device;

  @override
  String get id => device.peripheral.uuid.toString();
  @override
  String? get name => device.advertisement.name;
  @override
  int? get rssi => device.rssi;

  @override
  BleConnector createConnector() {
    return BluetoothLowEnergyConnector(
      backend: backend,
      serviceIds: serviceIds,
      peripheral: device.peripheral,
    );
  }
}
