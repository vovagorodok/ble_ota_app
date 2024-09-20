import 'dart:async';

import 'package:meta/meta.dart';
import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';

abstract class BleScanner extends StatefulNotifier<BleScannerState> {
  Future<void> scan();
  Future<void> stop();
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.devices,
    required this.scanIsInProgress,
  });

  final List<BlePeripheral> devices;
  final bool scanIsInProgress;
}
