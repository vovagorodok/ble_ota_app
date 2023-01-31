import 'package:ble_ota_app/src/core/software.dart';

class RemoteInfo {
  RemoteInfo({
    this.hardwareName = "",
    this.hardwareIcon,
    this.softwareList = const [],
    this.newestSoftware,
    this.unregisteredHardware = false,
  });

  String hardwareName;
  String? hardwareIcon;
  List<Software> softwareList;
  Software? newestSoftware;
  bool unregisteredHardware;
}
