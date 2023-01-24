import 'package:ble_ota_app/src/core/version.dart';
import 'package:meta/meta.dart';

@immutable
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
