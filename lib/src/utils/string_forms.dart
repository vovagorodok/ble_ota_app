import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/ble_ota/uploader.dart';
import 'package:ble_ota_app/src/core/errors.dart';

String determineUploadError(UploadState state) {
  switch (state.error) {
    case UploadError.generalDeviceError:
      return tr('UploadError');
    case UploadError.incorrectPackageFormat:
      return tr('IncorrectPackageFormat');
    case UploadError.incorrectFirmwareSize:
      return tr('IncorrectFirmwareSize');
    case UploadError.incorrectChecksum:
      return tr('ChecksumError');
    case UploadError.internalSrorageError:
      return tr('InternalStorageError');
    case UploadError.noDeviceResponse:
      return tr('NoDeviceResponse');
    case UploadError.unexpectedDeviceResponse:
      return tr('UnexpectedDeviceResponse', args: ['${state.errorCode}']);
    case UploadError.unexpectedNetworkResponse:
      return tr('UnexpectedNetworkResponse', args: ['${state.errorCode}']);
    case UploadError.generalNetworkError:
      return tr('NetworkError');
    default:
      return tr('UnknownError', args: ['${state.errorCode}']);
  }
}

String createDeviceString(infoState, name, version) =>
    infoState.isReady ? "$name v$version" : tr('Loading..');
String createHardwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.hardwareName,
    infoState.deviceInfo.hardwareVersion);
String createSoftwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.softwareName,
    infoState.deviceInfo.softwareVersion);
