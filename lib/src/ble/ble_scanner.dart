import 'dart:async';

import 'package:meta/meta.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

abstract class BleScanner extends StatefulStream<BleScannerState> {
  Future<void> scan();
  Future<void> stop();
}

@immutable
class BleScannedDevice {
  const BleScannedDevice({
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
    required this.devices,
    required this.scanIsInProgress,
  });

  final List<BleScannedDevice> devices;
  final bool scanIsInProgress;
}
