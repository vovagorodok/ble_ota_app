import 'package:meta/meta.dart';
import 'package:ble_ota_app/src/core/version.dart';

@immutable
class DeviceInfo {
  const DeviceInfo({
    this.hardwareName = "",
    this.hardwareVersion = const Version(),
    this.softwareName = "",
    this.softwareVersion = const Version(),
  });

  final String hardwareName;
  final Version hardwareVersion;
  final String softwareName;
  final Version softwareVersion;
}
