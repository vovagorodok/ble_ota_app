import 'dart:async';
import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart' as backend;
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class UniversalBleCharacteristic extends BleCharacteristic {
  UniversalBleCharacteristic(
      {required this.deviceId,
      required this.serviceId,
      required this.characteristicId});

  final String deviceId;
  final String serviceId;
  final String characteristicId;

  @override
  Future<Uint8List> read() async {
    return await backend.UniversalBle.readValue(
        deviceId, serviceId, characteristicId);
  }

  @override
  Future<void> write(Uint8List data) async {
    await backend.UniversalBle.writeValue(deviceId, serviceId, characteristicId,
        data, backend.BleOutputProperty.withResponse);
  }

  @override
  Future<void> writeWithoutResponse(Uint8List data) async {
    await backend.UniversalBle.writeValue(deviceId, serviceId, characteristicId,
        data, backend.BleOutputProperty.withoutResponse);
  }

  @override
  Future<void> startNotifications() async {
    backend.UniversalBle.onValueChange =
        (String deviceId, String characteristicId, Uint8List value) {
      if (characteristicId == this.characteristicId) {
        notifyData(value);
      }
    };
    backend.UniversalBle.setNotifiable(deviceId, serviceId, characteristicId,
        backend.BleInputProperty.notification);
  }

  @override
  Future<void> stopNotifications() async {
    backend.UniversalBle.onValueChange = null;
    backend.UniversalBle.setNotifiable(deviceId, serviceId, characteristicId,
        backend.BleInputProperty.disabled);
  }
}
