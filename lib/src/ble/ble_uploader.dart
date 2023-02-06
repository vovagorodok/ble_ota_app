import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/timer_wrapper.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_consts.dart';

class BleUploader extends StatefulStream<BleUploadState> {
  BleUploader({required this.deviceId})
      : _characteristicRx =
            _crateCharacteristic(characteristicUuidRx, deviceId),
        _characteristicTx =
            _crateCharacteristic(characteristicUuidTx, deviceId);

  final String deviceId;
  final QualifiedCharacteristic _characteristicRx;
  final QualifiedCharacteristic _characteristicTx;
  final _responseGuard = TimerWrapper();
  late StreamSubscription _subscription;
  BleUploadState _state = BleUploadState();
  Uint8List _dataToSend = Uint8List(0);
  int _currentDataPos = 0;
  int _currentBufferSize = 0;
  int _packageMaxSize = 0;
  int _bufferMaxSize = 0;

  @override
  BleUploadState get state => _state;

  void upload(Uint8List data) {
    _subscribeToCharacteristic();

    _state = BleUploadState(status: BleUploadStatus.begin);
    addStateToStream(state);
    _dataToSend = data;
    _sendBegin();
  }

  @override
  Future<void> dispose() async {
    _subscription.cancel();
    _responseGuard.stop();
    super.dispose();
  }

  void _raiseError(UploadError error, {int errorCode = 0}) {
    _subscription.cancel();
    state.status = BleUploadStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    addStateToStream(state);
  }

  void _waitForResponse() {
    _responseGuard.start(const Duration(seconds: 20),
        () => _raiseError(UploadError.noDeviceResponse));
  }

  void _sendData(List<int> data) {
    ble.writeCharacteristicWithoutResponse(_characteristicRx, value: data);
  }

  void _sendBegin() {
    _sendData(
        _uint8ToBytes(HeadCode.begin) + _uint32ToBytes(_dataToSend.length));
    _waitForResponse();
  }

  void _handleResp(Uint8List data) {
    _responseGuard.stop();
    var headCode = _bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      if (state.status == BleUploadStatus.begin) {
        _handleBeginResp(data);
        _sendPackages();
      } else if (state.status == BleUploadStatus.upload) {
        _sendPackages();
      } else if (state.status == BleUploadStatus.end) {
        _subscription.cancel();
        _dataToSend = Uint8List(0);
        state.status = BleUploadStatus.success;
        addStateToStream(state);
      } else {
        _raiseError(UploadError.unexpectedDeviceResponse);
      }
    } else {
      _raiseError(
        determineErrorHeadCode(headCode),
        errorCode: headCode,
      );
    }
  }

  void _handleBeginResp(Uint8List data) {
    state.status = BleUploadStatus.upload;
    addStateToStream(state);
    _currentDataPos = 0;
    _currentBufferSize = 0;
    _packageMaxSize = _bytesToUint32(data, attrSizePos) - headCodeBytesNum;
    _bufferMaxSize = _bytesToUint32(data, bufferSizePos);

    ble.requestMtu(
        deviceId: deviceId,
        mtu: _packageMaxSize + headCodeBytesNum + mtuOverheadBytesNum);
  }

  void _sendPackages() {
    while (_currentDataPos < _dataToSend.length) {
      var packageSize =
          min(_dataToSend.length - _currentDataPos, _packageMaxSize);
      var packageEndPos = _currentDataPos + packageSize;

      _sendData(_uint8ToBytes(HeadCode.package) +
          _dataToSend.sublist(_currentDataPos, packageEndPos));
      _currentDataPos = packageEndPos;

      state.progress =
          _currentDataPos.toDouble() / _dataToSend.length.toDouble();
      addStateToStream(state);

      _currentBufferSize += packageSize;
      if (_currentBufferSize > _bufferMaxSize) {
        _currentBufferSize = packageSize;
        _waitForResponse();
        return;
      }
    }

    _sendEnd();
  }

  void _sendEnd() {
    _sendData(
        _uint8ToBytes(HeadCode.end) + _uint32ToBytes(getCrc32(_dataToSend)));
    state.status = BleUploadStatus.end;
    _waitForResponse();
  }

  Uint8List _uint8ToBytes(int value) =>
      Uint8List(1)..buffer.asByteData().setUint8(0, value);

  Uint8List _uint32ToBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

  int _bytesToUint8(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint8(offset);

  int _bytesToUint32(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint32(offset, Endian.little);

  void _subscribeToCharacteristic() {
    _subscription = ble
        .subscribeToCharacteristic(_characteristicTx)
        .listen((event) => _handleResp(Uint8List.fromList(event)));
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class BleUploadState extends WorkState<BleUploadStatus, UploadError> {
  BleUploadState({
    super.status = BleUploadStatus.idle,
    super.error = UploadError.unknown,
    this.progress = 0.0,
  });

  double progress;
}

enum BleUploadStatus {
  idle,
  begin,
  upload,
  end,
  success,
  error,
}
