import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/flutter_reactive_ble_scanner.dart';

class FlutterReactiveBleCentral extends BleCentral {
  FlutterReactiveBleCentral({required this.backend})
      : _status = _convertToCentralStatus(backend.status) {
    backend.statusStream.listen(_updateState);
  }

  final FlutterReactiveBle backend;
  BleCentralStatus _status;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner({required List<String> serviceIds}) {
    return FlutterReactiveBleScanner(
        backend: backend, serviceIds: _convertToUuids(serviceIds));
  }

  void _updateState(BleStatus update) {
    _updateCentralStatus(_convertToCentralStatus(update));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    _status = status;
    notifyState(_status);
  }

  static List<Uuid> _convertToUuids(List<String> ids) {
    return ids.map((data) => Uuid.parse(data)).toList();
  }

  static BleCentralStatus _convertToCentralStatus(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return BleCentralStatus.unsupported;
      case BleStatus.unauthorized:
        return BleCentralStatus.unauthorized;
      case BleStatus.poweredOff:
        return BleCentralStatus.poweredOff;
      case BleStatus.locationServicesDisabled:
        return BleCentralStatus.locationServicesDisabled;
      case BleStatus.ready:
        return BleCentralStatus.ready;
      default:
        return BleCentralStatus.unknown;
    }
  }
}
