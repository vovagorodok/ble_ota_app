import 'dart:async';

import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import "package:flutter_web_bluetooth/js_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_peripheral.dart';

class FlutterWebBluetoothScanner extends BleScanner {
  FlutterWebBluetoothScanner({required this.serviceIds}) {
    FlutterWebBluetooth.instance.devices.listen((devices) {
      for (var device in devices) {
        _addScannedDevice(_createScannedDevice(device));
      }
      notifyState(state);
    });
  }

  List<String> serviceIds;
  final List<BlePeripheral> _devices = [];
  bool _scanIsInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        scanIsInProgress: _scanIsInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();

    final requestOptions =
        RequestOptionsBuilder([RequestFilterBuilder(services: serviceIds)]);

    _scanIsInProgress = true;
    notifyState(state);

    try {
      await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      // ignore: empty_catches
    } on UserCancelledDialogError {
      // ignore: empty_catches
    } on DeviceNotFoundError {}

    _scanIsInProgress = false;
    notifyState(state);
  }

  @override
  Future<void> stop() async {}

  void _addScannedDevice(BlePeripheral device) {
    final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = device;
    } else {
      _devices.add(device);
    }
  }

  static BlePeripheral _createScannedDevice(BluetoothDevice device) {
    return FlutterWebBluetoothPeripheral(device: device);
  }
}
