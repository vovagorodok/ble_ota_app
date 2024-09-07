import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class BluetoothLowEnergyCharacteristic extends BleCharacteristic {
  BluetoothLowEnergyCharacteristic(
      {required this.backend,
      required this.peripheral,
      required this.serviceId,
      required this.characteristicId});

  final CentralManager backend;
  final Peripheral peripheral;
  final UUID serviceId;
  final UUID characteristicId;
  late StreamSubscription _subscription;

  @override
  Future<List<int>> read() async {
    final characteristic = await _getCharacteristic();
    return (await backend.readCharacteristic(peripheral, characteristic))
        .buffer
        .asInt8List();
  }

  @override
  Future<void> write(List<int> data) async {
    final characteristic = await _getCharacteristic();
    await backend.writeCharacteristic(peripheral, characteristic,
        value: Uint8List.fromList(data),
        type: GATTCharacteristicWriteType.withResponse);
  }

  @override
  Future<void> writeWithoutResponse(List<int> data) async {
    final characteristic = await _getCharacteristic();
    await backend.writeCharacteristic(peripheral, characteristic,
        value: Uint8List.fromList(data),
        type: GATTCharacteristicWriteType.withoutResponse);
  }

  @override
  void subscribe({required void Function(List<int>) onData}) {
    subscribeAsync(onData: onData);
  }

  @override
  void unsubscribe() {
    unsubscribeAsync();
  }

  @override
  void dispose() {
    unsubscribe();
  }

  Future<void> subscribeAsync(
      {required void Function(List<int>) onData}) async {
    final characteristic = await _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic,
        state: true);
    _subscription = backend.characteristicNotified.listen((data) {
      if (data.characteristic.uuid != characteristicId) return;
      onData(data.value.buffer.asInt8List());
    });
  }

  Future<void> unsubscribeAsync() async {
    final characteristic = await _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic,
        state: false);
    _subscription.cancel();
  }

  Future<GATTCharacteristic> _getCharacteristic() async {
    final services = await backend.discoverGATT(peripheral);
    final service = services.firstWhere((d) => d.uuid == serviceId);
    final characteristic =
        service.characteristics.firstWhere((d) => d.uuid == characteristicId);
    return characteristic;
  }
}
