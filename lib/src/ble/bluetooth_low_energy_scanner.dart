import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_peripheral.dart';

class BluetoothLowEnergyScanner extends BleScanner {
  BluetoothLowEnergyScanner({required this.backend, required this.serviceIds}) {
    backend.discovered.listen(_addScannedDevice);
  }

  final CentralManager backend;
  final List<UUID> serviceIds;
  final List<BlePeripheral> _devices = [];
  bool _scanIsInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        scanIsInProgress: _scanIsInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    _scanIsInProgress = true;
    await backend.startDiscovery(serviceUUIDs: serviceIds);
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    if (!_scanIsInProgress) return;
    _scanIsInProgress = false;
    await backend.stopDiscovery();
    notifyState(state);
  }

  void _addScannedDevice(DiscoveredEventArgs device) {
    final scannedDevice = _createScannedDevice(device);
    final knownDeviceIndex =
        _devices.indexWhere((d) => d.id == scannedDevice.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = scannedDevice;
    } else {
      _devices.add(scannedDevice);
    }
    notifyState(state);
  }

  BlePeripheral _createScannedDevice(DiscoveredEventArgs device) {
    return BluetoothLowEnergyPeripheral(
      backend: backend,
      serviceIds: serviceIds,
      device: device,
    );
  }
}
