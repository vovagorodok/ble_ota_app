import 'package:ble_ota_app/src/core/version.dart';

class SoftwareInfo {
  SoftwareInfo({
    required this.name,
    required this.ver,
    required this.path,
  });

  String name;
  Version ver;
  String path;
}
