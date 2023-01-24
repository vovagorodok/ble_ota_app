import 'package:meta/meta.dart';

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
