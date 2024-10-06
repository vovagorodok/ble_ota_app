import 'dart:async';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import "package:flutter_web_bluetooth/js_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_backend/base_ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_backend/flutter_web_bluetooth_peripheral.dart';

class FlutterWebBluetoothScanner extends BaseBleScanner {
  FlutterWebBluetoothScanner({required this.serviceIds}) {
    FlutterWebBluetooth.instance.devices.listen((devices) {
      for (var device in devices) {
        addPeripheral(_createPeripheral(device));
      }
    });
  }

  List<String> serviceIds;
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    devices.clear();

    final requestOptions =
        RequestOptionsBuilder([RequestFilterBuilder(services: serviceIds)]);

    _isScanInProgress = true;
    notifyState(state);

    try {
      await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      // ignore: empty_catches
    } on UserCancelledDialogError {
      // ignore: empty_catches
    } on DeviceNotFoundError {}

    _isScanInProgress = false;
    notifyState(state);
  }

  @override
  Future<void> stop() async {}

  static BlePeripheral _createPeripheral(BluetoothDevice device) {
    return FlutterWebBluetoothPeripheral(device: device);
  }
}
