import 'dart:async';

import 'package:ble_ota_app/src/core/timer_wrapper.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class BleSerial {
  BleSerial(
      {required BleCharacteristic characteristicRx,
      required BleCharacteristic characteristicTx})
      : _characteristicRx = characteristicRx,
        _characteristicTx = characteristicTx;

  final BleCharacteristic _characteristicRx;
  final BleCharacteristic _characteristicTx;
  final _responseGuard = TimerWrapper();

  Future<void> send(List<int> data) async {
    await _characteristicRx.writeWithoutResponse(data);
  }

  void waitForResponse({required void Function() timeoutCallback}) {
    _responseGuard.start(const Duration(seconds: 20), timeoutCallback);
  }

  void subscribe({required void Function(List<int>) onData}) {
    _characteristicTx.subscribe(onData: (event) {
      _responseGuard.stop();
      onData(event);
    });
  }

  void unsubscribe() {
    _characteristicTx.unsubscribe();
  }

  void dispose() {
    unsubscribe();
    _responseGuard.stop();
  }
}
