import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/base_ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_mtu.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_characteristic.dart';

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
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    // _updateConnectorStatus(BleConnectorStatus.connecting);
    await backend.connect(peripheral);
  }

  @override
  Future<void> disconnect() async {
    // _updateConnectorStatus(BleConnectorStatus.disconnecting);
    await backend.disconnect(peripheral);
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 2)}) async {
    _updateConnectorStatus(BleConnectorStatus.scanning);
    await Future.delayed(duration);
    await connect();
  }

  @override
  BleMtu createMtu() {
    return BluetoothLowEnergyMtu(backend: backend, peripheral: peripheral);
  }

  @override
  BleCharacteristic createCharacteristic(
      String serviceId, String characteristicId) {
    return BluetoothLowEnergyCharacteristic(
        backend: backend,
        peripheral: peripheral,
        serviceId: UUID.fromString(serviceId),
        characteristicId: UUID.fromString(characteristicId));
  }

  void _updateState(PeripheralConnectionStateChangedEventArgs update) {
    if (update.peripheral != peripheral) return;
    _updateConnectorStatus(_convertToConnecorStatus(update.state));
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    _state = status;
    notifyState(_state);
  }

  static BleConnectorStatus _convertToConnecorStatus(ConnectionState state) {
    return state == ConnectionState.connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected;
  }
}
