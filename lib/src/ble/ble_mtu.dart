import 'dart:async';

abstract class BleMtu {
  bool get isSupported;
  Future<int> request(int mtu);
}
