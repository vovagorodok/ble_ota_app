import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_backend/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_connector.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_backend/flutter_web_bluetooth_scanner.dart';

class FlutterWebBluetoothCentral extends BleCentral {
  FlutterWebBluetoothCentral()
      : _status = FlutterWebBluetooth.instance.isBluetoothApiSupported
            ? BleCentralStatus.unknown
            : BleCentralStatus.unsupportedBrowser {
    if (_status == BleCentralStatus.unsupportedBrowser) return;
    FlutterWebBluetooth.instance.isAvailable.listen(_updateState);
  }

  BleCentralStatus _status;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner({required List<String> serviceIds}) {
    return FlutterWebBluetoothScanner(serviceIds: serviceIds);
  }

  @override
  BleConnector createConnectorToKnownDevice(
      {required String deviceId, required List<String> serviceIds}) {
    throw UnsupportedError;
  }

  @override
  bool get isCreateConnectorToKnownDeviceSupported => false;

  void _updateState(bool update) {
    _updateCentralStatus(_convertToCentralStatus(update));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    if (_status == status) return;
    _status = status;
    notifyState(_status);
  }

  static BleCentralStatus _convertToCentralStatus(bool isAvailable) {
    return isAvailable ? BleCentralStatus.ready : BleCentralStatus.poweredOff;
  }
}
