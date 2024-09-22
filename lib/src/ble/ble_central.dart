import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';

abstract class BleCentral extends StatefulNotifier<BleCentralStatus> {
  BleScanner createScaner({required List<String> serviceIds});
}

enum BleCentralStatus {
  unknown,
  unsupported,
  unsupportedBrowser,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready
}
