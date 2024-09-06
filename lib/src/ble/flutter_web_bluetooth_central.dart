import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/base_ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_scanner.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_connector.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_mtu.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_characteristic.dart';

class FlutterWebBluetoothCentral extends BaseBleCentral {
  FlutterWebBluetoothCentral()
      : _status = FlutterWebBluetooth.instance.isBluetoothApiSupported
            ? BleCentralStatus.unknown
            : BleCentralStatus.unsupported {
    if (_status == BleCentralStatus.unsupported) return;
    // FlutterWebBluetooth.instance.isAvailable.listen(_updateState);
    FlutterWebBluetooth.instance.devices.listen((devices) {
      for (var device in devices) {
        _addDevice(device);
      }
    });
  }

  BleCentralStatus _status;
  final _devices = <BluetoothDevice>[];

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner(List<String> serviceIds) {
    return FlutterWebBluetoothScanner(serviceIds: serviceIds);
  }

  @override
  BleConnector createConnector(String deviceId, List<String> serviceIds) {
    return FlutterWebBluetoothConnector(device: _getDevice(deviceId));
  }

  @override
  BleMtu createMtu(String deviceId) {
    return FlutterWebBluetoothMtu(deviceId: deviceId);
  }

  @override
  BleCharacteristic createCharacteristic(
      String deviceId, String serviceId, String characteristicId) {
    return FlutterWebBluetoothCharacteristic(
        device: _getDevice(deviceId),
        serviceId: serviceId,
        characteristicId: characteristicId);
  }

  @override
  BleSerial createSerial(String deviceId, String serviceId,
      String rxCharacteristicId, String txCharacteristicId) {
    return BleSerial(
      characteristicRx:
          createCharacteristic(deviceId, serviceId, rxCharacteristicId),
      characteristicTx:
          createCharacteristic(deviceId, serviceId, txCharacteristicId),
    );
  }

  void _addDevice(BluetoothDevice device) {
    final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = device;
    } else {
      _devices.add(device);
    }
  }

  void _updateState(bool update) {
    _updateCentralStatus(_convertToCentralStatus(update));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    if (_status == status) return;
    _status = status;
    addStateToStream(_status);
  }

  BluetoothDevice _getDevice(String deviceId) {
    return _devices.firstWhere((d) => d.id == deviceId);
  }

  static BleCentralStatus _convertToCentralStatus(bool isAvailable) {
    return isAvailable ? BleCentralStatus.ready : BleCentralStatus.poweredOff;
  }
}
