import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_scanner.dart';

class BluetoothLowEnergyCentral extends BleCentral {
  BluetoothLowEnergyCentral({required this.backend})
      : _status = _convertToCentralStatus(backend.state) {
    backend.stateChanged.listen(_updateState);
  }

  final CentralManager backend;
  BleCentralStatus _status;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner({required List<String> serviceIds}) {
    return BluetoothLowEnergyScanner(
        backend: backend, serviceIds: _convertToUuids(serviceIds));
  }

  void _updateState(BluetoothLowEnergyStateChangedEventArgs update) {
    _updateCentralStatus(_convertToCentralStatus(update.state));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    _status = status;
    notifyState(_status);
  }

  static List<UUID> _convertToUuids(List<String> ids) {
    return ids.map((data) => UUID.fromString(data)).toList();
  }

  static BleCentralStatus _convertToCentralStatus(
      BluetoothLowEnergyState state) {
    switch (state) {
      case BluetoothLowEnergyState.unsupported:
        return BleCentralStatus.unsupported;
      case BluetoothLowEnergyState.unauthorized:
        return BleCentralStatus.unauthorized;
      case BluetoothLowEnergyState.poweredOff:
        return BleCentralStatus.poweredOff;
      case BluetoothLowEnergyState.poweredOn:
        return BleCentralStatus.ready;
      default:
        return BleCentralStatus.unknown;
    }
  }
}
