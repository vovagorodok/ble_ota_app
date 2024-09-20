import 'package:universal_ble/universal_ble.dart' as backend;
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/universal_ble_scanner.dart';

class UniversalBleCentral extends BleCentral {
  UniversalBleCentral() {
    backend.UniversalBle.getBluetoothAvailabilityState().then(_updateState);
    backend.UniversalBle.onAvailabilityChange = _updateState;
  }

  BleCentralStatus _status = BleCentralStatus.unknown;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner(List<String> serviceIds) {
    return UniversalBleScanner(serviceIds: serviceIds);
  }

  void _updateState(backend.AvailabilityState update) {
    _updateCentralStatus(_convertToCentralStatus(update));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    if (_status == status) return;
    _status = status;
    notifyState(_status);
  }

  static BleCentralStatus _convertToCentralStatus(
      backend.AvailabilityState status) {
    switch (status) {
      case backend.AvailabilityState.unsupported:
        return BleCentralStatus.unsupported;
      case backend.AvailabilityState.unauthorized:
        return BleCentralStatus.unauthorized;
      case backend.AvailabilityState.poweredOff:
        return BleCentralStatus.poweredOff;
      case backend.AvailabilityState.poweredOn:
        return BleCentralStatus.ready;
      default:
        return BleCentralStatus.unknown;
    }
  }
}
