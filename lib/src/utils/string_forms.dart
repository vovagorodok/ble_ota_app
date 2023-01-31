import 'package:ble_ota_app/src/ble_ota/ble_ota_upload_error.dart';

String determineBleOtaUploadError(BleOtaUploadError error, int code) {
  switch (error) {
    case BleOtaUploadError.generalDeviceError:
      return "Upload error";
    case BleOtaUploadError.incorrectPackageFormat:
      return "Incorrect package format";
    case BleOtaUploadError.incorrectFirmwareSize:
      return "Incorrect firmware size";
    case BleOtaUploadError.incorrectChecksum:
      return "Checksum error";
    case BleOtaUploadError.internalSrorageError:
      return "Internal storage error";
    case BleOtaUploadError.unexpectedDeviceResponce:
      return "Unexpected device responce: $code";
    case BleOtaUploadError.unexpectedNetworkResponce:
      return "Unexpected network responce: $code";
    case BleOtaUploadError.generalNetworkError:
      return "Network error";
    default:
      return "Unknown error: $code";
  }
}
