import 'dart:async';
import 'dart:typed_data';

import 'package:ble_ota_app/src/utils/converters.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/ble/ble_consts.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

class BlePinChanger extends StatefulNotifier<BlePinChangeState> {
  BlePinChanger({required BleCentral bleCentral, required String deviceId})
      : _bleSerial = bleCentral.createSerial(
            deviceId, serviceUuid, characteristicUuidRx, characteristicUuidTx);

  final BleSerial _bleSerial;
  StreamSubscription? _subscription;
  BlePinChangeState _state = BlePinChangeState();

  @override
  BlePinChangeState get state => _state;

  void set(int pin) {
    _begin();
    _send(HeadCode.setPin, uint32ToBytes(pin));
    _waitForResponse();
  }

  void remove() {
    _begin();
    _send(HeadCode.removePin, Uint8List(0));
    _waitForResponse();
  }

  @override
  void dispose() {
    _unsubscribe();
    _bleSerial.dispose();
    super.dispose();
  }

  void _begin() {
    _bleSerial.startNotifications();
    _subscription = _bleSerial.dataStream
        .listen((data) => _handleResp(Uint8List.fromList(data)));

    _state = BlePinChangeState(status: WorkStatus.working);
    notifyState(state);
  }

  void _raiseError(PinChangeError error, {int errorCode = 0}) {
    _unsubscribe();
    state.status = WorkStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    notifyState(state);
  }

  void _waitForResponse() {
    _bleSerial.waitData(
        timeoutCallback: () => _raiseError(PinChangeError.noDeviceResponse));
  }

  void _send(int head, Uint8List data) {
    _bleSerial.send(Uint8List.fromList(uint8ToBytes(head) + data));
  }

  void _handleResp(Uint8List data) {
    if (state.status != WorkStatus.working) {
      _raiseError(PinChangeError.unexpectedDeviceResponse);
      return;
    }

    final headCode = bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      _unsubscribe();
      state.status = WorkStatus.success;
      notifyState(state);
    } else {
      _raiseError(
        PinChangeError.generalDeviceError,
        errorCode: headCode,
      );
    }
  }

  void _unsubscribe() {
    _bleSerial.stopNotifications();
    _subscription?.cancel();
  }
}

class BlePinChangeState extends WorkState<WorkStatus, PinChangeError> {
  BlePinChangeState({
    super.status = WorkStatus.idle,
    super.error = PinChangeError.unknown,
  });
}
