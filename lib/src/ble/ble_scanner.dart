import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class BleScanner extends StatefulStream<BleScanState> {
  final _devices = <DiscoveredDevice>[];
  final _scanDuration = const Duration(seconds: 10);
  StreamSubscription? _subscription;

  @override
  BleScanState get state => BleScanState(
        discoveredDevices: _devices,
        scanIsInProgress: _subscription != null,
      );

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
      addStateToStream(state);
    }, onError: (Object e) {});
    addStateToStream(state);

    Future.delayed(_scanDuration, () {
      stopScan();
    });
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    addStateToStream(state);
  }
}

@immutable
class BleScanState {
  const BleScanState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}

final bleScanner = BleScanner();
