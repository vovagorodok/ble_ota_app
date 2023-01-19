import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_uuids.dart';

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
  final StreamController<Info> _infoStreamController = StreamController();

  Stream<Info> get infoStream => _infoStreamController.stream;

  Info info = Info(
    hwName: "",
    hwVer: const Version(major: 0, minor: 0, patch: 0),
    swName: "",
    swVer: const Version(major: 0, minor: 0, patch: 0),
  );

  Version _convertToVer(List<int> data) =>
      Version(major: data[0], minor: data[1], patch: data[2]);

  void update() {
    () async {
      info.hwName = String.fromCharCodes(
          await ble.readCharacteristic(_characteristicHwName));
      info.hwVer =
          _convertToVer(await ble.readCharacteristic(_characteristicHwVer));
      info.swName = String.fromCharCodes(
          await ble.readCharacteristic(_characteristicSwName));
      info.swVer =
          _convertToVer(await ble.readCharacteristic(_characteristicSwVer));

      _infoStreamController.add(info);
    }.call();
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class Info {
  Info({
    required this.hwName,
    required this.hwVer,
    required this.swName,
    required this.swVer,
  });

  String hwName;
  Version hwVer;
  String swName;
  Version swVer;
}

@immutable
class Version {
  const Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  final int major;
  final int minor;
  final int patch;
}
