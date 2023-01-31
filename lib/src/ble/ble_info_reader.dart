import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleInfoReader extends StatefulStream<DeviceInfoState> {
  BleInfoReader({required String deviceId})
      : _characteristicHardwareName =
            _crateCharacteristic(characteristicUuidHardwareName, deviceId),
        _characteristicHardwareVersion =
            _crateCharacteristic(characteristicUuidHardwareVersion, deviceId),
        _characteristicSoftwareName =
            _crateCharacteristic(characteristicUuidSoftwareName, deviceId),
        _characteristicSoftwareVersion =
            _crateCharacteristic(characteristicUuidSoftwareVersion, deviceId);

  final QualifiedCharacteristic _characteristicHardwareName;
  final QualifiedCharacteristic _characteristicHardwareVersion;
  final QualifiedCharacteristic _characteristicSoftwareName;
  final QualifiedCharacteristic _characteristicSoftwareVersion;
  final DeviceInfoState _state = DeviceInfoState();

  @override
  DeviceInfoState get state => _state;

  void read() {
    state.isReady = false;
    addStateToStream(state);

    () async {
      state.info = DeviceInfo(
        hardwareName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicHardwareName)),
        hardwareVersion: Version.fromList(
            await ble.readCharacteristic(_characteristicHardwareVersion)),
        softwareName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicSoftwareName)),
        softwareVersion: Version.fromList(
            await ble.readCharacteristic(_characteristicSoftwareVersion)),
      );
      state.isReady = true;

      addStateToStream(state);
    }.call();
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class DeviceInfoState {
  DeviceInfoState({
    this.info = const DeviceInfo(),
    this.isReady = false,
  });

  DeviceInfo info;
  bool isReady;
}
