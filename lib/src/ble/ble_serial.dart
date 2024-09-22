import 'dart:async';
import 'dart:typed_data';

import 'package:ble_ota_app/src/core/data_notifier.dart';
import 'package:ble_ota_app/src/core/timer_wrapper.dart';
import 'package:ble_ota_app/src/ble/ble_characteristic.dart';

class BleSerial extends DataNotifier<Uint8List> {
  BleSerial(
      {required BleCharacteristic characteristicRx,
      required BleCharacteristic characteristicTx})
      : _characteristicRx = characteristicRx,
        _characteristicTx = characteristicTx {
    _subscription = _characteristicTx.dataStream.listen((data) {
      _responseGuard.stop();
      notifyData(data);
    });
  }

  final BleCharacteristic _characteristicRx;
  final BleCharacteristic _characteristicTx;
  final _responseGuard = TimerWrapper();
  StreamSubscription? _subscription;

  Future<void> send({required Uint8List data}) async {
    await _characteristicRx.writeWithoutResponse(data: data);
  }

  void waitData(
      {required void Function() timeoutCallback,
      Duration duration = const Duration(seconds: 20)}) {
    _responseGuard.start(duration, timeoutCallback);
  }

  Future<void> startNotifications() async {
    await _characteristicTx.startNotifications();
  }

  Future<void> stopNotifications() async {
    await _characteristicTx.stopNotifications();
    _responseGuard.stop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _responseGuard.stop();
    super.dispose();
  }
}
