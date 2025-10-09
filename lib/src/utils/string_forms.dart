import 'package:ble_ota/ble_ota.dart';
import 'package:ble_ota/core/errors.dart';
import 'package:ble_ota/core/version.dart';
import 'package:easy_localization/easy_localization.dart';

String determineError(BleOtaState state) {
  switch (state.error) {
    case Error.deviceError:
      return tr('DeviceError');
    case Error.noDeviceResponse:
      return tr('NoDeviceResponse');
    case Error.unexpectedDeviceResponse:
      return tr('UnexpectedDeviceResponse', args: ['${state.errorCode}']);
    case Error.incorrectDeviceResponse:
      return tr('IncorrectDeviceResponse');

    case Error.networkError:
      return tr('NetworkError');
    case Error.unexpectedNetworkResponse:
      return tr('UnexpectedNetworkResponse', args: ['${state.errorCode}']);
    case Error.incorrectNetworkFile:
      return tr('IncorrectNetworkFile');

    case Error.incorrectMessageSize:
      return tr('IncorrectMessageSize');
    case Error.incorrectMessageHeader:
      return tr('IncorrectMessageHeader');
    case Error.incorrectFirmwareSize:
      return tr('IncorrectFirmwareSize');
    case Error.internalStorageError:
      return tr('InternalStorageError');
    case Error.uploadDisabled:
      return tr('UploadDisabled');
    case Error.uploadRunning:
      return tr('UploadRunning');
    case Error.uploadStopped:
      return tr('UploadStopped');
    case Error.installRunning:
      return tr('InstallRunning');
    case Error.bufferDisabled:
      return tr('BufferDisabled');
    case Error.bufferOverflow:
      return tr('BufferOverflow');
    case Error.compressionNotSupported:
      return tr('CompressionNotSupported');
    case Error.incorrectCompression:
      return tr('IncorrectCompression');
    case Error.incorrectCompressedSize:
      return tr('IncorrectCompressedSize');
    case Error.incorrectCompressionChecksum:
      return tr('IncorrectCompressionChecksum');
    case Error.incorrectCompressionParam:
      return tr('IncorrectCompressionParam');
    case Error.incorrectCompressionEnd:
      return tr('IncorrectCompressionEnd');
    case Error.checksumNotSupported:
      return tr('ChecksumNotSupported');
    case Error.incorrectChecksum:
      return tr('IncorrectChecksum');
    case Error.signatureNotSupported:
      return tr('SignatureNotSupported');
    case Error.incorrectSignature:
      return tr('IncorrectSignature');
    case Error.incorrectSignatureSize:
      return tr('IncorrectSignatureSize');
    case Error.pinNotSupported:
      return tr('PinNotSupported');
    case Error.pinChangeError:
      return tr('PinChangeError');

    default:
      return tr('UnknownError', args: ['${state.errorCode}']);
  }
}

String createDeviceString(
    BleOtaState bleOtaState, String name, Version version) {
  if (bleOtaState.deviceInfo.isAvailable) {
    return "$name v$version";
  } else if (bleOtaState.status == BleOtaStatus.init) {
    return tr('Loading..');
  } else {
    return tr('NoInformation');
  }
}

String createHardwareString(BleOtaState bleOtaState) => createDeviceString(
    bleOtaState,
    bleOtaState.deviceInfo.hardwareName,
    bleOtaState.deviceInfo.hardwareVersion);
String createSoftwareString(BleOtaState bleOtaState) => createDeviceString(
    bleOtaState,
    bleOtaState.deviceInfo.softwareName,
    bleOtaState.deviceInfo.softwareVersion);
