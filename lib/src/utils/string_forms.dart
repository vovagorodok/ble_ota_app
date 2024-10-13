import 'package:easy_localization/easy_localization.dart';
import 'package:ble_backend/work_state.dart';
import 'package:ble_ota/core/errors.dart';
import 'package:ble_ota/ble/ble_pin_changer.dart';
import 'package:ble_ota/info_reader.dart';
import 'package:ble_ota/uploader.dart';

String determineInfoError(InfoState state) {
  switch (state.error) {
    case InfoError.incorrectFileFormat:
      return tr('IncorrectFileFormat');
    case InfoError.unexpectedNetworkResponse:
      return tr('UnexpectedNetworkResponse', args: ['${state.errorCode}']);
    case InfoError.generalNetworkError:
      return tr('NetworkError');
    default:
      return tr('UnknownError', args: ['${state.errorCode}']);
  }
}

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
    case UploadError.uploadDisabled:
      return tr('UploadDisabled');
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

String determinePinChangeError(BlePinChangeState state) {
  switch (state.error) {
    case PinChangeError.generalDeviceError:
      return tr('PinCodeHasNotBeenChanged');
    case PinChangeError.noDeviceResponse:
      return tr('NoDeviceResponse');
    case PinChangeError.unexpectedDeviceResponse:
      return tr('UnexpectedDeviceResponse', args: ['${state.errorCode}']);
    default:
      return tr('UnknownError', args: ['${state.errorCode}']);
  }
}

String createDeviceString(infoState, name, version) {
  if (infoState.status == WorkStatus.success) {
    return "$name v$version";
  } else if (infoState.status == WorkStatus.working) {
    return tr('Loading..');
  } else {
    return tr('NoInformation');
  }
}

String createHardwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.hardwareName,
    infoState.deviceInfo.hardwareVersion);
String createSoftwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.softwareName,
    infoState.deviceInfo.softwareVersion);
