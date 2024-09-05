import 'dart:async';
import 'dart:typed_data';

import 'package:ble_ota_app/src/utils/converters.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/ble/ble_consts.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

class BlePinChanger extends StatefulStream<BlePinChangeState> {
  BlePinChanger({required BleCentral bleCentral, required String deviceId})
      : _bleSerial = bleCentral.createSerial(
            deviceId, serviceUuid, characteristicUuidRx, characteristicUuidTx);

  final BleSerial _bleSerial;
  BlePinChangeState _state = BlePinChangeState();

  @override
  BlePinChangeState get state => _state;

  void set(int pin) {
    _begin();
    _sendData(uint8ToBytes(HeadCode.setPin) + uint32ToBytes(pin));
    _waitForResponse();
  }

  void remove() {
    _begin();
    _sendData(uint8ToBytes(HeadCode.removePin));
    _waitForResponse();
  }

  @override
  Future<void> dispose() async {
    _bleSerial.dispose();
    super.dispose();
  }

  void _begin() {
    _bleSerial.subscribe(
        onData: (event) => _handleResp(Uint8List.fromList(event)));

    _state = BlePinChangeState(status: WorkStatus.working);
    addStateToStream(state);
  }

  void _raiseError(PinChangeError error, {int errorCode = 0}) {
    _bleSerial.unsubscribe();
    state.status = WorkStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    addStateToStream(state);
  }

  void _waitForResponse() {
    _bleSerial.waitForResponse(
        timeoutCallback: () => _raiseError(PinChangeError.noDeviceResponse));
  }

  void _sendData(List<int> data) {
    _bleSerial.send(data);
  }

  void _handleResp(Uint8List data) {
    if (state.status != WorkStatus.working) {
      _raiseError(PinChangeError.unexpectedDeviceResponse);
      return;
    }

    var headCode = bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      _bleSerial.unsubscribe();
      state.status = WorkStatus.success;
      addStateToStream(state);
    } else {
      _raiseError(
        PinChangeError.generalDeviceError,
        errorCode: headCode,
      );
    }
  }
}

class BlePinChangeState extends WorkState<WorkStatus, PinChangeError> {
  BlePinChangeState({
    super.status = WorkStatus.idle,
    super.error = PinChangeError.unknown,
  });
}
