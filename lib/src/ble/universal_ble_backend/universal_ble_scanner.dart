import 'dart:async';

import 'package:universal_ble/universal_ble.dart';
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/universal_ble_backend/universal_ble_peripheral.dart';

class UniversalBleScanner extends BaseBleScanner {
  UniversalBleScanner({required this.serviceIds}) {
    UniversalBle.onScanResult =
        (device) => addPeripheral(_createPeripheral(device));
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
    await UniversalBle.startScan(
        scanFilter: ScanFilter(
      withServices: serviceIds,
    ));
    _isScanInProgress = true;
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    await UniversalBle.stopScan();
    _isScanInProgress = false;
    notifyState(state);
  }

  BlePeripheral _createPeripheral(BleDevice device) {
    return UniversalBlePeripheral(
      device: device,
      serviceIds: serviceIds,
    );
  }
}
