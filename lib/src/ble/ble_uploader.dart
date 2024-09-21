import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:ble_ota_app/src/utils/converters.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_notifier.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/ble/ble_consts.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';
import 'package:ble_ota_app/src/settings/settings.dart';

class BleUploader extends StatefulNotifier<BleUploadState> {
  BleUploader(
      {required BleConnector bleConnector, bool sequentialUpload = false})
      : _bleMtu = bleConnector.createMtu(),
        _bleSerial = bleConnector.createSerial(
            serviceUuid, characteristicUuidRx, characteristicUuidTx),
        _sequentialUpload = sequentialUpload;

  final BleMtu _bleMtu;
  final BleSerial _bleSerial;
  final bool _sequentialUpload;
  StreamSubscription? _subscription;
  BleUploadState _state = BleUploadState();
  Uint8List _dataToSend = Uint8List(0);
  int _currentDataPos = 0;
  int _currentBufferSize = 0;
  int _packageMaxSize = 0;
  int _bufferMaxSize = 0;

  @override
  BleUploadState get state => _state;

  Future<void> upload(Uint8List data) async {
    try {
      await _bleSerial.startNotifications();
      _subscription = _bleSerial.dataStream.listen(_handleResp);
      _state = BleUploadState(status: BleUploadStatus.begin);
      notifyState(state);
      _packageMaxSize = await _calcPackageMaxSize();
      _dataToSend = data;
      _sendBegin();
    } catch (_) {
      _raiseError(UploadError.generalDeviceError);
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    _bleSerial.dispose();
    super.dispose();
  }

  Future<int> _calcPackageMaxSize() async {
    final maxMtu = maxMtuSize.value.toInt();
    final mtu = _bleMtu.isSupported ? await _bleMtu.request(maxMtu) : maxMtu;
    return mtu - mtuWriteOverheadBytesNum - headCodeBytesNum;
  }

  Future<void> _send(int head, Uint8List data) async {
    await _bleSerial.send(Uint8List.fromList(uint8ToBytes(head) + data));
  }

  void _raiseError(UploadError error, {int errorCode = 0}) {
    _unsubscribe();
    state.status = BleUploadStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    notifyState(state);
  }

  void _waitForResponse() {
    _bleSerial.waitData(
        timeoutCallback: () => _raiseError(UploadError.noDeviceResponse));
  }

  void _sendBegin() {
    _send(HeadCode.begin, uint32ToBytes(_dataToSend.length));
    _waitForResponse();
  }

  void _handleResp(Uint8List data) {
    final headCode = bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      if (state.status == BleUploadStatus.begin) {
        _handleBeginResp(data);
        _sendPackages();
      } else if (state.status == BleUploadStatus.upload) {
        _sendPackages();
      } else if (state.status == BleUploadStatus.end) {
        _unsubscribe();
        _dataToSend = Uint8List(0);
        state.status = BleUploadStatus.success;
        notifyState(state);
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
    notifyState(state);
    _currentDataPos = 0;
    _currentBufferSize = 0;
    _packageMaxSize = min(
        _packageMaxSize, bytesToUint32(data, attrSizePos) - headCodeBytesNum);
    _bufferMaxSize = bytesToUint32(data, bufferSizePos);
  }

  void _sendPackages() async {
    while (_currentDataPos < _dataToSend.length) {
      final packageSize =
          min(_dataToSend.length - _currentDataPos, _packageMaxSize);
      final packageEndPos = _currentDataPos + packageSize;
      final package = _dataToSend.sublist(_currentDataPos, packageEndPos);

      _sequentialUpload
          ? await _send(HeadCode.package, package)
          : _send(HeadCode.package, package);
      _currentDataPos = packageEndPos;

      state.progress =
          _currentDataPos.toDouble() / _dataToSend.length.toDouble();
      notifyState(state);

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
    _send(HeadCode.end, uint32ToBytes(getCrc32(_dataToSend)));
    state.status = BleUploadStatus.end;
    _waitForResponse();
  }

  void _unsubscribe() {
    _bleSerial.stopNotifications();
    _subscription?.cancel();
  }
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
