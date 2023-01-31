import 'package:meta/meta.dart';
import 'package:ble_ota_app/src/core/version.dart';

@immutable
class SoftwareInfo {
  const SoftwareInfo({
    this.name = "",
    this.version = const Version(),
    this.path = "",
    this.icon,
    this.hardwareVersion,
    this.minHardwareVersion,
    this.maxHardwareVersion,
  });

  static SoftwareInfo fromJson(json) => SoftwareInfo(
        name: json["software_name"],
        version: Version.fromList(json["software_version"]),
        path: json["software_path"],
        icon: json["software_icon"],
        hardwareVersion: _getOptionalVersion(json, "hardware_version"),
        minHardwareVersion: _getOptionalVersion(json, "min_hardware_version"),
        maxHardwareVersion: _getOptionalVersion(json, "max_hardware_version"),
      );

  @override
  String toString() {
    return "$name v$version";
  }

  static _getOptionalVersion(json, key) =>
      json.containsKey(key) ? Version.fromList(json[key]) : null;

  final String name;
  final Version version;
  final String path;
  final String? icon;
  final Version? hardwareVersion;
  final Version? minHardwareVersion;
  final Version? maxHardwareVersion;
}
