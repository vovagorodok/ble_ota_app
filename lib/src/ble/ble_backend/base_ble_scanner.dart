import 'package:meta/meta.dart';

import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';

abstract class BaseBleScanner extends BleScanner {
  @protected
  final List<BlePeripheral> devices = [];

  @protected
  void addPeripheral(BlePeripheral device) {
    final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
    if (knownDeviceIndex >= 0) {
      devices[knownDeviceIndex] = device;
    } else {
      devices.add(device);
    }
    notifyState(state);
  }
}
