import 'package:ble_backend/ble_connector.dart';
import 'package:ble_backend/ble_characteristic.dart';
import 'package:ble_backend/state_notifier.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleInfoReader extends StatefulNotifier<DeviceInfoState> {
  BleInfoReader({required BleConnector bleConnector})
      : _characteristicManufactureName = bleConnector.createCharacteristic(
            serviceId: serviceUuid,
            characteristicId: characteristicUuidManufactureName),
        _characteristicHardwareName = bleConnector.createCharacteristic(
            serviceId: serviceUuid,
            characteristicId: characteristicUuidHardwareName),
        _characteristicHardwareVersion = bleConnector.createCharacteristic(
            serviceId: serviceUuid,
            characteristicId: characteristicUuidHardwareVersion),
        _characteristicSoftwareName = bleConnector.createCharacteristic(
            serviceId: serviceUuid,
            characteristicId: characteristicUuidSoftwareName),
        _characteristicSoftwareVersion = bleConnector.createCharacteristic(
            serviceId: serviceUuid,
            characteristicId: characteristicUuidSoftwareVersion);

  final BleCharacteristic _characteristicManufactureName;
  final BleCharacteristic _characteristicHardwareName;
  final BleCharacteristic _characteristicHardwareVersion;
  final BleCharacteristic _characteristicSoftwareName;
  final BleCharacteristic _characteristicSoftwareVersion;
  final DeviceInfoState _state = DeviceInfoState();

  @override
  DeviceInfoState get state => _state;

  void read() {
    state.status = WorkStatus.working;
    notifyState(state);

    () async {
      state.info = DeviceInfo(
        manufactureName:
            String.fromCharCodes(await _characteristicManufactureName.read()),
        hardwareName:
            String.fromCharCodes(await _characteristicHardwareName.read()),
        hardwareVersion:
            Version.fromList(await _characteristicHardwareVersion.read()),
        softwareName:
            String.fromCharCodes(await _characteristicSoftwareName.read()),
        softwareVersion:
            Version.fromList(await _characteristicSoftwareVersion.read()),
      );
      state.status = WorkStatus.success;

      notifyState(state);
    }.call();
  }
}

class DeviceInfoState extends WorkState<WorkStatus, InfoError> {
  DeviceInfoState({
    super.status = WorkStatus.idle,
    super.error = InfoError.unknown,
    this.info = const DeviceInfo(),
  });

  DeviceInfo info;
}
