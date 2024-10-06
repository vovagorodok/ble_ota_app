import 'dart:async';

import 'package:win_ble/win_ble.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_peripheral.dart';

class WinBleScanner extends BleScanner {
  WinBleScanner({required this.serviceIds}) {
    WinBle.scanStream.listen((device) {
      for (final serviceId in serviceIds) {
        if (!device.serviceUuids
            .any((id) => id.substring(1, id.length - 1) == serviceId)) return;
      }
      _addPeripheral(_createPeripheral(device));
      notifyState(state);
    });
  }

  final List<String> serviceIds;
  final List<BlePeripheral> _devices = [];
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    WinBle.startScanning();
    _isScanInProgress = true;
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    WinBle.stopScanning();
    _isScanInProgress = false;
    notifyState(state);
  }

  void _addPeripheral(BlePeripheral device) {
    final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = device;
    } else {
      _devices.add(device);
    }
  }

  BlePeripheral _createPeripheral(BleDevice device) {
    return WinBlePeripheral(
      device: device,
      serviceIds: serviceIds,
    );
  }
}
