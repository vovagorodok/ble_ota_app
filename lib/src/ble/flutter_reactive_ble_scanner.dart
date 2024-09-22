import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/flutter_reactive_ble_peripheral.dart';

class FlutterReactiveBleScanner extends BleScanner {
  FlutterReactiveBleScanner({required this.backend, required this.serviceIds});

  final FlutterReactiveBle backend;
  final List<Uuid> serviceIds;
  final List<BlePeripheral> _devices = [];
  StreamSubscription? _subscription;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        isScanInProgress: _subscription != null,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    _subscription?.cancel();
    _subscription = backend
        .scanForDevices(withServices: serviceIds)
        .listen(_addScannedDevice, onError: (Object e) {});
    notifyState(state);
  }

  void _addScannedDevice(DiscoveredDevice device) {
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

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    notifyState(state);
  }

  BlePeripheral _createScannedDevice(DiscoveredDevice device) {
    return FlutterReactiveBlePeripheral(
      backend: backend,
      serviceIds: serviceIds,
      discoveredDevice: device,
    );
  }
}
