import 'dart:async';

import 'package:universal_ble/universal_ble.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';

class UniversalBleConnector extends BleConnector {
  UniversalBleConnector({required this.deviceId, required this.serviceIds}) {
    UniversalBle.onConnectionChange = (String deviceId, bool isConnected) {
      if (deviceId != this.deviceId) return;
      if (isConnected) return;
      _updateConnectorStatus(BleConnectorStatus.disconnected);
      // Library require discover services bifore use
      // _updateConnectorStatus(isConnected
      //     ? BleConnectorStatus.connected
      //     : BleConnectorStatus.disconnected);
    };
  }

  final String deviceId;
  final List<String> serviceIds;
  BleConnectorStatus _state = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _state;

  @override
  Future<void> connect() async {
    if (!await UniversalBle.connect(deviceId)) return;
    await UniversalBle.discoverServices(deviceId);
    _updateConnectorStatus(BleConnectorStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    await UniversalBle.disconnect(deviceId);
    _updateConnectorStatus(BleConnectorStatus.disconnected);
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 2)}) async {}

  void _updateConnectorStatus(BleConnectorStatus status) {
    if (_state == status) return;
    _state = status;
    notifyState(_state);
  }
}
