import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_backend/bluetooth_low_energy_mtu.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_backend/bluetooth_low_energy_characteristic.dart';

class BluetoothLowEnergyConnector extends BaseBleConnector {
  BluetoothLowEnergyConnector(
      {required this.backend,
      required this.serviceIds,
      required this.peripheral}) {
    backend.connectionStateChanged.listen(_updateState);
  }

  final CentralManager backend;
  final List<UUID> serviceIds;
  final Peripheral peripheral;
  BleConnectorStatus _status = BleConnectorStatus.disconnected;
  List<GATTService>? _services;

  @override
  BleConnectorStatus get state => _status;

  @override
  Future<void> connect() async {
    await backend.connect(peripheral);
  }

  @override
  Future<void> disconnect() async {
    await backend.disconnect(peripheral);
  }

  @override
  Future<void> connectToKnownDevice(
      {Duration duration = const Duration(seconds: 2)}) async {
    throw UnsupportedError;
  }

  @override
  bool get isConnectToKnownDeviceSupported => false;

  @override
  Future<List<String>> discoverServices() async {
    return _services!.map((service) => service.uuid.toString()).toList();
  }

  @override
  BleMtu createMtu() {
    return BluetoothLowEnergyMtu(backend: backend, peripheral: peripheral);
  }

  @override
  BleCharacteristic createCharacteristic(
      {required String serviceId, required String characteristicId}) {
    return BluetoothLowEnergyCharacteristic(
        backend: backend,
        connector: this,
        peripheral: peripheral,
        serviceId: UUID.fromString(serviceId),
        characteristicId: UUID.fromString(characteristicId));
  }

  GATTCharacteristic? getCharacteristic(UUID serviceId, UUID characteristicId) {
    if (_status != BleConnectorStatus.connected) return null;
    final service = _services!.firstWhere((d) => d.uuid == serviceId);
    return service.characteristics
        .firstWhere((d) => d.uuid == characteristicId);
  }

  void _updateState(PeripheralConnectionStateChangedEventArgs update) {
    if (update.peripheral != peripheral) return;

    if (update.state == ConnectionState.connected) {
      backend.discoverGATT(peripheral).then((services) {
        _services = services;
        _updateConnectorStatus(BleConnectorStatus.connected);
      });
    } else {
      _updateConnectorStatus(BleConnectorStatus.disconnected);
      _services = null;
    }
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    _status = status;
    notifyState(_status);
  }
}
