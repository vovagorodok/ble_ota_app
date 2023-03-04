import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/timer_wrapper.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';

class BleSerial {
  BleSerial({required deviceId})
      : _characteristicRx =
            _crateCharacteristic(characteristicUuidRx, deviceId),
        _characteristicTx =
            _crateCharacteristic(characteristicUuidTx, deviceId);

  final QualifiedCharacteristic _characteristicRx;
  final QualifiedCharacteristic _characteristicTx;
  final _responseGuard = TimerWrapper();
  late StreamSubscription _subscription;

  void sendData(List<int> data) {
    ble.writeCharacteristicWithoutResponse(_characteristicRx, value: data);
  }

  void waitForResponse({required void Function() timeoutCallback}) {
    _responseGuard.start(const Duration(seconds: 20), timeoutCallback);
  }

  void subscribe({required void Function(List<int>) onData}) {
    _subscription =
        ble.subscribeToCharacteristic(_characteristicTx).listen((event) {
      _responseGuard.stop();
      onData(event);
    });
  }

  void unsubscribe() {
    _subscription.cancel();
  }

  void dispose() {
    unsubscribe();
    _responseGuard.stop();
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}
