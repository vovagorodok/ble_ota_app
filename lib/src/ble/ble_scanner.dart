import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class BleScanner {

  final StreamController<BleScannerState> _stateStreamController =
      StreamController();
  final _devices = <DiscoveredDevice>[];
  StreamSubscription? _subscription;

  BleScannerState get state => BleScannerState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      );

  Stream<BleScannerState> get stateStream => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        ble.scanForDevices(withServices: serviceIds).listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      _stateStreamController.add(state);
    }, onError: (Object e) {});
    _stateStreamController.add(state);
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    _stateStreamController.add(state);
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}

final bleScanner = BleScanner();