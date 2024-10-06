import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/bluez_backend/bluez_peripheral.dart';

class BlueZScanner extends BleScanner {
  BlueZScanner({required this.client, required this.serviceIds}) {
    client.deviceAdded.listen((device) {
      int index = _devices.indexWhere((d) => d.id == device.address);
      if (index == -1) {
        _devices.add(_createPeripheral(device));
      } else {
        _devices[index] = _createPeripheral(device);
      }
      notifyState(state);
    });
  }

  final BlueZClient client;
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
