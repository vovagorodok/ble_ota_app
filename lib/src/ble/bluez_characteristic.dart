import 'dart:async';
import 'dart:typed_data';

import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class BlueZCharacteristic extends BleCharacteristic {
  BlueZCharacteristic(
      {required this.device,
      required this.serviceId,
      required this.characteristicId});

  final BlueZDevice device;
  final BlueZUUID serviceId;
  final BlueZUUID characteristicId;

  @override
  Future<Uint8List> read() async {
    return Uint8List.fromList(await _getCharacteristic().readValue());
  }

  @override
  Future<void> write({required Uint8List data}) async {
    await _getCharacteristic()
        .writeValue(data, type: BlueZGattCharacteristicWriteType.request);
  }

  @override
  Future<void> writeWithoutResponse({required Uint8List data}) async {
    await _getCharacteristic()
        .writeValue(data, type: BlueZGattCharacteristicWriteType.command);
  }

  @override
  Future<void> startNotifications() async {
    await _getCharacteristic().startNotify();
  }

  @override
  Future<void> stopNotifications() async {
    await _getCharacteristic().stopNotify();
  }

  BlueZGattCharacteristic _getCharacteristic() {
    final service =
        device.gattServices.firstWhere((service) => service.uuid == serviceId);
    return service.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == characteristicId);
  }
}
