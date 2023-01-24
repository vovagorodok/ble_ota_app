import 'dart:async';

import 'package:ble_ota_app/src/core/hardware_info.dart';
import 'package:ble_ota_app/src/core/version.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleInfoReader {
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
  final StreamController<InfoState> _infoStreamController = StreamController();

  Stream<InfoState> get infoStream => _infoStreamController.stream;

  InfoState infoState = InfoState(
    hwInfo: HardwareInfo(
      hwName: "",
      hwVer: const Version(major: 0, minor: 0, patch: 0),
      swName: "",
      swVer: const Version(major: 0, minor: 0, patch: 0),
    ),
    ready: false,
  );

  Version _convertToVer(List<int> data) =>
      Version(major: data[0], minor: data[1], patch: data[2]);

  void read() {
    infoState.ready = false;
    _infoStreamController.add(infoState);

    () async {
      infoState.hwInfo.hwName = String.fromCharCodes(
          await ble.readCharacteristic(_characteristicHwName));
      infoState.hwInfo.hwVer =
          _convertToVer(await ble.readCharacteristic(_characteristicHwVer));
      infoState.hwInfo.swName = String.fromCharCodes(
          await ble.readCharacteristic(_characteristicSwName));
      infoState.hwInfo.swVer =
          _convertToVer(await ble.readCharacteristic(_characteristicSwVer));
      infoState.ready = true;

      _infoStreamController.add(infoState);
    }.call();
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class InfoState {
  InfoState({
    required this.hwInfo,
    required this.ready,
  });

  HardwareInfo hwInfo;
  bool ready;
}
