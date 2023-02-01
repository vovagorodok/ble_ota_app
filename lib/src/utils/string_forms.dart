import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/core/upload_error.dart';

String determineUploadError(UploadError error, int code) {
  switch (error) {
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
    case UploadError.unexpectedDeviceResponce:
      return tr('UnexpectedDeviceResponce', args: ['$code']);
    case UploadError.unexpectedNetworkResponce:
      return tr('UnexpectedNetworkResponce', args: ['$code']);
    case UploadError.generalNetworkError:
      return tr('NetworkError');
    default:
      return tr('UnknownError', args: ['$code']);
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
