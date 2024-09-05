import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';

class FlutterReactiveBleScanner extends BleScanner {
  FlutterReactiveBleScanner({required this.backend, required this.serviceIds});

  final FlutterReactiveBle backend;
  final List<Uuid> serviceIds;
  final _devices = <BleScannedDevice>[];
  StreamSubscription? _subscription;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        scanIsInProgress: _subscription != null,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        backend.scanForDevices(withServices: serviceIds).listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = _createScannedDevice(device);
      } else {
        _devices.add(_createScannedDevice(device));
      }
      addStateToStream(state);
    }, onError: (Object e) {});
    addStateToStream(state);
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    addStateToStream(state);
  }

  BleScannedDevice _createScannedDevice(DiscoveredDevice device) {
    return BleScannedDevice(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
    );
  }
}
