import 'package:meta/meta.dart';

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

@immutable
class Version {
  const Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  final int major;
  final int minor;
  final int patch;
}
