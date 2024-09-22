import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_connector.dart';

class BluetoothLowEnergyCharacteristic extends BleCharacteristic {
  BluetoothLowEnergyCharacteristic(
      {required this.backend,
      required this.connector,
      required this.peripheral,
      required this.serviceId,
      required this.characteristicId});

  final CentralManager backend;
  final BluetoothLowEnergyConnector connector;
  final Peripheral peripheral;
  final UUID serviceId;
  final UUID characteristicId;
  StreamSubscription? _subscription;

  @override
  Future<Uint8List> read() async {
    final characteristic = _getCharacteristic();
    return await backend.readCharacteristic(peripheral, characteristic!);
  }

  @override
  Future<void> write({required Uint8List data}) async {
    final characteristic = _getCharacteristic();
    await backend.writeCharacteristic(peripheral, characteristic!,
        value: data, type: GATTCharacteristicWriteType.withResponse);
  }

  @override
  Future<void> writeWithoutResponse({required Uint8List data}) async {
    final characteristic = _getCharacteristic();
    await backend.writeCharacteristic(peripheral, characteristic!,
        value: data, type: GATTCharacteristicWriteType.withoutResponse);
  }

  @override
  Future<void> startNotifications() async {
    final characteristic = _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic!,
        state: true);
    _subscription = backend.characteristicNotified.listen((data) {
      if (data.peripheral.uuid != peripheral.uuid ||
          data.characteristic.uuid != characteristicId) return;
      notifyData(data.value);
    });
  }

  @override
  Future<void> stopNotifications() async {
    final characteristic = _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic!,
        state: false);
    await _subscription?.cancel();
  }

  GATTCharacteristic? _getCharacteristic() {
    return connector.getCharacteristic(serviceId, characteristicId);
  }
}
