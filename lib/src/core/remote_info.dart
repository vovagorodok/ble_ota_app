import 'package:ble_ota_app/src/core/software.dart';

class RemoteInfo {
  RemoteInfo({
    this.hardwareName = "",
    this.hardwareIcon,
    this.hardwareText,
    this.hardwarePage,
    this.softwareList = const [],
    this.newestSoftware,
    this.isHardwareUnregistered = false,
  });

  String hardwareName;
  String? hardwareIcon;
  String? hardwareText;
  String? hardwarePage;
  List<Software> softwareList;
  Software? newestSoftware;
  bool isHardwareUnregistered;
}
