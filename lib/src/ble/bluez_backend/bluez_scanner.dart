import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/bluez_backend/bluez_peripheral.dart';

class BlueZScanner extends BaseBleScanner {
  BlueZScanner({required this.client, required this.serviceIds}) {
    client.deviceAdded
        .listen((device) => addPeripheral(_createPeripheral(device)));
  }

  final BlueZClient client;
  final List<String> serviceIds;
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    await client.adapters.first.setDiscoveryFilter(uuids: serviceIds);
    await client.adapters.first.startDiscovery();
    _isScanInProgress = true;
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    if (!_isScanInProgress) return;
    await client.adapters.first.stopDiscovery();
    _isScanInProgress = false;
    notifyState(state);
  }

  BlePeripheral _createPeripheral(BlueZDevice device) {
    return BlueZPeripheral(
      device: device,
      serviceIds: serviceIds,
    );
  }
}
