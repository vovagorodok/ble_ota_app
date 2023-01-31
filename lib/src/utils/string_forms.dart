import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/core/upload_error.dart';

String determineUploadError(UploadError error, int code) {
  switch (error) {
    case UploadError.generalDeviceError:
      return "Upload error";
    case UploadError.incorrectPackageFormat:
      return "Incorrect package format";
    case UploadError.incorrectFirmwareSize:
      return "Incorrect firmware size";
    case UploadError.incorrectChecksum:
      return "Checksum error";
    case UploadError.internalSrorageError:
      return "Internal storage error";
    case UploadError.unexpectedDeviceResponce:
      return "Unexpected device responce: $code";
    case UploadError.unexpectedNetworkResponce:
      return "Unexpected network responce: $code";
    case UploadError.generalNetworkError:
      return "Network error";
    default:
      return "Unknown error: $code";
  }
}

String createDeviceString(infoState, name, version) =>
    infoState.isReady ? "$name v$version" : "loading..";
String createHardwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.hardwareName,
    infoState.deviceInfo.hardwareVersion);
String createSoftwareString(InfoState infoState) => createDeviceString(
    infoState,
    infoState.deviceInfo.softwareName,
    infoState.deviceInfo.softwareVersion);
