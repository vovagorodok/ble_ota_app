import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

class BleCentral extends StatefulStream<BleCentralStatus> {
  BleCentral({required this.backend})
      : _status = _convertToCentralStatus(backend.status) {
    backend.statusStream.listen(_updateState);
  }

  final FlutterReactiveBle backend;
  BleCentralStatus _status;

  @override
  BleCentralStatus get state => _status;

  BleScanner createScaner(List<String> serviceIds) {
    return BleScanner(
        backend: backend, serviceIds: _convertToUuids(serviceIds));
  }

  BleConnector createConnector(String deviceId, List<String> serviceIds) {
    return BleConnector(
        backend: backend,
        deviceId: deviceId,
        serviceIds: _convertToUuids(serviceIds));
  }

  BleCharacteristic createCharacteristic(
      String deviceId, String serviceId, String characteristicId) {
    return BleCharacteristic(
        backend: backend,
        deviceId: deviceId,
        serviceId: Uuid.parse(serviceId),
        characteristicId: Uuid.parse(characteristicId));
  }

  BleSerial createSerial(String deviceId, String serviceId,
      String rxCharacteristicId, String txCharacteristicId) {
    return BleSerial(
      characteristicRx:
          createCharacteristic(deviceId, serviceId, rxCharacteristicId),
      characteristicTx:
          createCharacteristic(deviceId, serviceId, txCharacteristicId),
    );
  }

  void _updateState(BleStatus update) {
    _notifyIfChanged(_convertToCentralStatus(update));
  }

  void _notifyIfChanged(BleCentralStatus newStatus) {
    if (newStatus != _status) {
      _status = newStatus;
      addStateToStream(state);
    }
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

enum BleCentralStatus {
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  locationServicesDisabled,
  ready
}
