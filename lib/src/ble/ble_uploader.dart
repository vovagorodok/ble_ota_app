import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_uuids.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_consts.dart';

class BleUploader {
  BleUploader({required String deviceId})
      : _characteristicRx =
            _crateCharacteristic(characteristicUuidRx, deviceId),
        _characteristicTx =
            _crateCharacteristic(characteristicUuidTx, deviceId) {
    ble
        .subscribeToCharacteristic(_characteristicTx)
        .listen((event) => _handleResp(Uint8List.fromList(event)));
    ble.requestMtu(deviceId: deviceId, mtu: 512 + 4); // TODO: fix and remove
  }

  final QualifiedCharacteristic _characteristicRx;
  final QualifiedCharacteristic _characteristicTx;
  final StreamController<UploadState> _stateStreamController =
      StreamController();
  Uint8List _dataToSend = Uint8List(0);
  int _dataToSendPos = 0;
  int _packageSize = 0;
  int _bufferSize = 0;

  Stream<UploadState> get stateStream => _stateStreamController.stream;

  UploadState state = UploadState(
    status: UploadStatus.idle,
    progress: 0.0,
    errorMsg: "",
  );

  Future<void> upload(Uint8List data) async {
    state.status = UploadStatus.idle;
    _stateStreamController.add(state);
    _dataToSend = data;
    await _sendBegin();
  }

  Future<void> _sendData(List<int> data) async {
    await ble.writeCharacteristicWithoutResponse(_characteristicRx,
        value: data);
  }

  Future<void> _sendBegin() async {
    await _sendData(
        _uint8ToBytes(HeadCode.begin) + _uint32ToBytes(_dataToSend.length));
  }

  Future<void> _handleResp(Uint8List data) async {
    var headCode = _bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      print("VOVA: resp ok");
      if (state.status == UploadStatus.idle) {
        await _handleBeginResp(data);
        await _sendPackages();
      } else if (state.status == UploadStatus.upload) {
        await _sendPackages();
      } else if (state.status == UploadStatus.end) {
        _stateStreamController.add(state);
        print("VOVA: success");
      }
    } else {
      state.status = UploadStatus.error;
      state.errorMsg = determineErrorHeadCode(headCode);
      _stateStreamController.add(state);
      print("VOVA: error: ${state.errorMsg}");
    }
  }

  Future<void> _handleBeginResp(Uint8List data) async {
    state.status = UploadStatus.upload;
    state.progress = 0.0;
    _stateStreamController.add(state);
    _dataToSendPos = 0;
    _packageSize = _bytesToUint32(data, attrSizePos) - headCodeBytesNum;
    _bufferSize = _bytesToUint32(data, bufferSizePos);
  }

  Future<void> _sendPackages() async {
    var dataToSendStartingPos = _dataToSendPos;

    while (_dataToSendPos < _dataToSend.length) {
      var packageSize = min(_dataToSend.length - _dataToSendPos, _packageSize);
      var dataToSendEndPos = _dataToSendPos + packageSize;

      await _sendData(_uint8ToBytes(HeadCode.package) +
          _dataToSend.sublist(_dataToSendPos, dataToSendEndPos));
      _dataToSendPos = dataToSendEndPos;

      state.progress =
          _dataToSendPos.toDouble() / _dataToSend.length.toDouble();
      _stateStreamController.add(state);

      print("VOVA: _dataToSend.length: ${_dataToSend.length}");
      print("VOVA: _dataToSendPos: ${_dataToSendPos}");
      print("VOVA: progress: ${state.progress}");

      if (_dataToSendPos - dataToSendStartingPos > _bufferSize) {
        return;
      }
    }

    await _sendEnd();
  }

  Future<void> _sendEnd() async {
    print("VOVA: send end");
    var crc32 = 0;
    await _sendData(_uint8ToBytes(HeadCode.end) + _uint32ToBytes(crc32));
    state.status = UploadStatus.end;
  }

  Uint8List _uint8ToBytes(int value) =>
      Uint8List(1)..buffer.asByteData().setUint8(0, value);

  Uint8List _uint32ToBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

  int _bytesToUint8(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint8(offset);

  int _bytesToUint32(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint32(offset, Endian.little);

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class UploadState {
  UploadState({
    required this.status,
    required this.progress,
    required this.errorMsg,
  });

  UploadStatus status;
  double progress;
  String errorMsg;
}

enum UploadStatus { idle, upload, end, error }
