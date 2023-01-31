import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleInfoReader extends StatefulStream<DeviceInfoState> {
  BleInfoReader({required String deviceId})
      : _characteristicHwName =
            _crateCharacteristic(characteristicUuidHwName, deviceId),
        _characteristicHwVer =
            _crateCharacteristic(characteristicUuidHwVer, deviceId),
        _characteristicSwName =
            _crateCharacteristic(characteristicUuidSwName, deviceId),
        _characteristicSwVer =
            _crateCharacteristic(characteristicUuidSwVer, deviceId);

  final QualifiedCharacteristic _characteristicHwName;
  final QualifiedCharacteristic _characteristicHwVer;
  final QualifiedCharacteristic _characteristicSwName;
  final QualifiedCharacteristic _characteristicSwVer;
  final DeviceInfoState _state = DeviceInfoState();

  @override
  DeviceInfoState get state => _state;

  void read() {
    state.ready = false;
    addStateToStream(state);

    () async {
      state.info = DeviceInfo(
        hardwareName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicHwName)),
        hardwareVersion: Version.fromList(
            await ble.readCharacteristic(_characteristicHwVer)),
        softwareName: String.fromCharCodes(
            await ble.readCharacteristic(_characteristicSwName)),
        softwareVersion: Version.fromList(
            await ble.readCharacteristic(_characteristicSwVer)),
      );
      state.ready = true;

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
    this.ready = false,
  });

  DeviceInfo info;
  bool ready;
}
