import 'package:meta/meta.dart';

@immutable
class Version {
  const Version({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
  });

  static Version fromList(list) => Version(
        major: list[0],
        minor: list[1],
        patch: list[2],
      );

  @override
  String toString() {
    return "$major.$minor.$patch";
  }

  final int major;
  final int minor;
  final int patch;
}
