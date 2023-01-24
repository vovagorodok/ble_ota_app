import 'package:ble_ota_app/src/core/version.dart';
import 'package:meta/meta.dart';

@immutable
class SoftwareInfo {
  const SoftwareInfo({
    this.name = "",
    this.ver = const Version(),
    this.path = "",
    this.icon,
    this.hwName = "",
    this.hwVer,
    this.minHwVer,
    this.maxHwVer,
  });

  static SoftwareInfo fromJson(json) => SoftwareInfo(
        name: json["software_name"],
        ver: Version.fromList(json["software_version"]),
        path: json["software_path"],
        hwName: json["hardware_name"],
        icon: json["software_icon"],
      );

  final String name;
  final Version ver;
  final String path;
  final String? icon;
  final String hwName;
  final Version? hwVer;
  final Version? minHwVer;
  final Version? maxHwVer;
}
