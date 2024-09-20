import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';

abstract class BleCentral extends StatefulNotifier<BleCentralStatus> {
  BleScanner createScaner(List<String> serviceIds); // TODO: named args?
}

enum BleCentralStatus {
  // TODO: Add unsupportedBrowser
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready
}
