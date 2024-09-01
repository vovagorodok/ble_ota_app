import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class BleScanner extends StatefulStream<BleScannerState> {
  BleScanner({required this.serviceIds});

  final List<Uuid> serviceIds;
  final _devices = <BlePeripheral>[];
  StreamSubscription? _subscription;

  @override
  BleScannerState get state => BleScannerState(
        peripherals: _devices,
        scanIsInProgress: _subscription != null,
      );

  Future<void> scan() async {
    _devices.clear();
    _subscription?.cancel();
    _subscription =
        ble.scanForDevices(withServices: serviceIds).listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = _createPeripheral(device);
      } else {
        _devices.add(_createPeripheral(device));
      }
      addStateToStream(state);
    }, onError: (Object e) {});
    addStateToStream(state);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    addStateToStream(state);
  }

  BlePeripheral _createPeripheral(DiscoveredDevice device) {
    return BlePeripheral(
      id: device.id,
      name: device.name,
      rssi: device.rssi,
    );
  }
}

@immutable
class BlePeripheral {
  const BlePeripheral({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final String id;
  final String name;
  final int rssi;
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.peripherals,
    required this.scanIsInProgress,
  });

  final List<BlePeripheral> peripherals;
  final bool scanIsInProgress;
}
