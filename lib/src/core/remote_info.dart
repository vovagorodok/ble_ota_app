import 'package:ble_ota_app/src/core/softwate_info.dart';

class RemoteInfo {
  RemoteInfo({
    this.hardwareName = "",
    this.hardwareIcon,
    this.softwareInfoList = const [],
    this.newestSoftware,
    this.unregisteredHardware = false,
  });

  String hardwareName;
  String? hardwareIcon;
  List<SoftwareInfo> softwareInfoList;
  SoftwareInfo? newestSoftware;
  bool unregisteredHardware;
}
