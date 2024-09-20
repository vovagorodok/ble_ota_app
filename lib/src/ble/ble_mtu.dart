import 'dart:async';

abstract class BleMtu {
  Future<int> request(int mtu);
  bool isSupported();
}
