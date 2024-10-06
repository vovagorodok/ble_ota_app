import 'package:win_ble/win_ble.dart';
import 'package:win_ble/win_file.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_connector.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_scanner.dart';
import 'package:ble_ota_app/src/ble/win_ble_backend/win_ble_connector.dart';

class WinBleCentral extends BleCentral {
  WinBleCentral() {
    WinBle.bleState.listen(_updateState);
    () async {
      await WinBle.initialize(serverPath: await WinServer.path());
    }.call();
  }

  BleCentralStatus _status = BleCentralStatus.unknown;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner({required List<String> serviceIds}) {
    return WinBleScanner(serviceIds: serviceIds);
  }

  @override
  BleConnector createConnectorToKnownDevice(
      {required String deviceId, required List<String> serviceIds}) {
    return WinBleConnector(deviceId: deviceId, serviceIds: serviceIds);
  }

  @override
  bool get isCreateConnectorToKnownDeviceSupported => true;

  void _updateState(BleState update) {
    _updateCentralStatus(_convertToCentralStatus(update));
  }

  void _updateCentralStatus(BleCentralStatus status) {
    if (_status == status) return;
    _status = status;
    notifyState(_status);
  }

  static BleCentralStatus _convertToCentralStatus(BleState status) {
    switch (status) {
      case BleState.Unsupported:
        return BleCentralStatus.unsupported;
      case BleState.Disabled:
        return BleCentralStatus.poweredOff;
      case BleState.Off:
        return BleCentralStatus.poweredOff;
      case BleState.On:
        return BleCentralStatus.ready;
      default:
        return BleCentralStatus.unknown;
    }
  }
}
