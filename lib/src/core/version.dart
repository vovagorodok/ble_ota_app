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

  bool operator <=(Version other) {
    if (major != other.major) {
      return major < other.major;
    }
    if (minor != other.minor) {
      return minor < other.minor;
    }
    if (patch != other.patch) {
      return patch < other.patch;
    }
    return true;
  }

  bool operator >=(Version other) {
    if (major != other.major) {
      return major > other.major;
    }
    if (minor != other.minor) {
      return minor > other.minor;
    }
    if (patch != other.patch) {
      return patch > other.patch;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is Version &&
        other.major == major &&
        other.minor == minor &&
        other.patch == patch;
  }

  @override
  int get hashCode => major.hashCode ^ minor.hashCode ^ patch.hashCode;

  final int major;
  final int minor;
  final int patch;
}
