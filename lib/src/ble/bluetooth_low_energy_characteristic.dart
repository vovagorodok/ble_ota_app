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
  StreamSubscription? _subscription;
  GATTCharacteristic? _characteristic;

  @override
  Future<List<int>> read() async {
    final characteristic = await _getCharacteristic();
    return (await backend.readCharacteristic(peripheral, characteristic));
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
  Future<void> startNotifications() async {
    final characteristic = await _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic,
        state: true);
    _subscription = backend.characteristicNotified.listen((data) {
      if (data.characteristic.uuid != characteristicId) return;
      notifyData(data.value);
    });
  }

  @override
  Future<void> stopNotifications() async {
    final characteristic = await _getCharacteristic();
    await backend.setCharacteristicNotifyState(peripheral, characteristic,
        state: false);
    await _subscription?.cancel();
  }

  Future<GATTCharacteristic> _getCharacteristic() async {
    // Library internal exception when writing large amount of data quickly
    Future.delayed(const Duration(milliseconds: 10));
    if (_characteristic == null) {
      final services = await backend.discoverGATT(peripheral);
      final service = services.firstWhere((d) => d.uuid == serviceId);
      final characteristic =
          service.characteristics.firstWhere((d) => d.uuid == characteristicId);
      _characteristic = characteristic;
    }
    return _characteristic!;
  }
}
