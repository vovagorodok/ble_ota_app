import 'package:ble_ota_app/src/core/version.dart';

class HardwareInfo {
  HardwareInfo({
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
