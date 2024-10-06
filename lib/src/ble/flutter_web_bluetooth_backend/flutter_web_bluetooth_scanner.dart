import 'dart:async';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import "package:flutter_web_bluetooth/js_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_backend/flutter_web_bluetooth_peripheral.dart';

class FlutterWebBluetoothScanner extends BleScanner {
  FlutterWebBluetoothScanner({required this.serviceIds}) {
    FlutterWebBluetooth.instance.devices.listen((devices) {
      for (var device in devices) {
        _addPeripheral(_createPeripheral(device));
      }
      notifyState(state);
    });
  }

  List<String> serviceIds;
  final List<BlePeripheral> _devices = [];
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();

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

  void _addPeripheral(BlePeripheral device) {
    final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = device;
    } else {
      _devices.add(device);
    }
  }

  static BlePeripheral _createPeripheral(BluetoothDevice device) {
    return FlutterWebBluetoothPeripheral(device: device);
  }
}
