import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';

class BluetoothLowEnergyConnector extends BleConnector {
  BluetoothLowEnergyConnector(
      {required this.backend,
      required this.peripheral,
      required this.serviceIds}) {
    backend.connectionStateChanged.listen(_updateState);
  }

  final CentralManager backend;
  final Peripheral peripheral;
  final List<UUID> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    _updateConnectorStatus(BleConnectorStatus.connecting);
    await backend.connect(peripheral);
  }

  @override
  Future<void> disconnect() async {
    _updateConnectorStatus(BleConnectorStatus.disconnecting);
    await backend.disconnect(peripheral);
  }

  @override
  Future<void> scanAndConnect() async {}

  void _updateState(PeripheralConnectionStateChangedEventArgs update) {
    if (update.peripheral != peripheral) return;
    _updateConnectorStatus(_convertToConnecorStatus(update.state));
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    _state = status;
    notifyStateUpdate(_state);
  }

  static BleConnectorStatus _convertToConnecorStatus(ConnectionState state) {
    return state == ConnectionState.connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected;
  }
}
