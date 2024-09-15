import 'dart:async';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_connector.dart';

class FlutterWebBluetoothConnector extends BleConnector {
  FlutterWebBluetoothConnector({required this.device}) {
    device.connected.listen(_updateConnected);
  }

  final BluetoothDevice device;
  BleConnectorStatus _status = BleConnectorStatus.disconnected;

  @override
  BleConnectorStatus get state => _status;

  @override
  Future<void> connect() async {
    await device.connect();
  }

  @override
  Future<void> disconnect() async {
    if (_status == BleConnectorStatus.connected) device.disconnect();
  }

  @override
  Future<void> scanAndConnect(
      {Duration duration = const Duration(seconds: 2)}) async {
    _updateConnectorStatus(BleConnectorStatus.scanning);
    await Future.delayed(duration);
    await connect();
  }

  void _updateConnected(bool connected) {
    _updateConnectorStatus(connected
        ? BleConnectorStatus.connected
        : BleConnectorStatus.disconnected);
  }

  void _updateConnectorStatus(BleConnectorStatus status) {
    if (_status == status) return;
    _status = status;
    notifyState(_status);
  }
}
