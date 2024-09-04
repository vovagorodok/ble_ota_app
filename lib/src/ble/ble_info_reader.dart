import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class BleInfoReader extends StatefulStream<DeviceInfoState> {
  BleInfoReader({required BleCentral bleCentral, required String deviceId})
      : _characteristicManufactureName = bleCentral.createCharacteristic(
            deviceId, serviceUuid, characteristicUuidManufactureName),
        _characteristicHardwareName = bleCentral.createCharacteristic(
            deviceId, serviceUuid, characteristicUuidHardwareName),
        _characteristicHardwareVersion = bleCentral.createCharacteristic(
            deviceId, serviceUuid, characteristicUuidHardwareVersion),
        _characteristicSoftwareName = bleCentral.createCharacteristic(
            deviceId, serviceUuid, characteristicUuidSoftwareName),
        _characteristicSoftwareVersion = bleCentral.createCharacteristic(
            deviceId, serviceUuid, characteristicUuidSoftwareVersion);

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
    addStateToStream(state);

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

      addStateToStream(state);
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
