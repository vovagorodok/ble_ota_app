import 'package:meta/meta.dart';
import 'package:ble_ota_app/src/core/version.dart';

@immutable
class Software {
  const Software({
    this.name = "",
    this.version = const Version(),
    this.path = "",
    this.icon,
    this.text,
    this.page,
    this.hardwareVersion,
    this.minHardwareVersion,
    this.maxHardwareVersion,
  });

  static Software fromDict(dict) => Software(
        name: dict["software_name"],
        version: Version.fromList(dict["software_version"]),
        path: dict["software_path"],
        icon: dict["software_icon"],
        text: dict["software_text"],
        page: dict["software_page"],
        hardwareVersion: _getOptionalVersion(dict, "hardware_version"),
        minHardwareVersion: _getOptionalVersion(dict, "min_hardware_version"),
        maxHardwareVersion: _getOptionalVersion(dict, "max_hardware_version"),
      );

  @override
  String toString() {
    return "$name v$version";
  }

  static _getOptionalVersion(dict, key) =>
      dict.containsKey(key) ? Version.fromList(dict[key]) : null;

  final String name;
  final Version version;
  final String path;
  final String? icon;
  final String? text;
  final String? page;
  final Version? hardwareVersion;
  final Version? minHardwareVersion;
  final Version? maxHardwareVersion;
}
