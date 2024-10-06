import 'dart:async';

abstract class BleMtu {
  Future<int> request({required int mtu});
  bool get isRequestSupported;
}
