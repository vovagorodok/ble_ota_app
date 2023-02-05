import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/core/upload_error.dart';

String determineUploadError(UploadError error) {
  switch (error.status) {
    case UploadErrorStatus.generalDeviceError:
      return tr('UploadError');
    case UploadErrorStatus.incorrectPackageFormat:
      return tr('IncorrectPackageFormat');
    case UploadErrorStatus.incorrectFirmwareSize:
      return tr('IncorrectFirmwareSize');
    case UploadErrorStatus.incorrectChecksum:
      return tr('ChecksumError');
    case UploadErrorStatus.internalSrorageError:
      return tr('InternalStorageError');
    case UploadErrorStatus.noDeviceResponse:
      return tr('NoDeviceResponse');
    case UploadErrorStatus.unexpectedDeviceResponse:
      return tr('UnexpectedDeviceResponse', args: ['${error.code}']);
    case UploadErrorStatus.unexpectedNetworkResponse:
      return tr('UnexpectedNetworkResponse', args: ['${error.code}']);
    case UploadErrorStatus.generalNetworkError:
      return tr('NetworkError');
    default:
      return tr('UnknownError', args: ['${error.code}']);
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
