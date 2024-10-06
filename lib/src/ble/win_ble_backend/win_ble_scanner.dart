import 'dart:async';

import 'package:win_ble/win_ble.dart';
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_peripheral.dart';

class WinBleScanner extends BaseBleScanner {
  WinBleScanner({required this.serviceIds}) {
    WinBle.scanStream.listen((device) {
      for (final serviceId in serviceIds) {
        if (!device.serviceUuids
            .any((id) => id.substring(1, id.length - 1) == serviceId)) return;
      }
      addPeripheral(_createPeripheral(device));
    });
  }

  final List<String> serviceIds;
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    devices.clear();
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

  BlePeripheral _createPeripheral(BleDevice device) {
    return WinBlePeripheral(
      device: device,
      serviceIds: serviceIds,
    );
  }
}
