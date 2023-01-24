import 'package:ble_ota_app/src/core/version.dart';

class HardwareInfo {
  const HardwareInfo({
    this.hwName = "",
    this.hwVer = const Version(),
    this.swName = "",
    this.swVer = const Version(),
  });

  final String hwName;
  final Version hwVer;
  final String swName;
  final Version swVer;
}
