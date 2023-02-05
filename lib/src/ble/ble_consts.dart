import 'package:ble_ota_app/src/core/errors.dart';

const uint8BytesNum = 1;
const uint32BytesNum = 4;
const mtuOverheadBytesNum = 4;
const headCodeBytesNum = uint8BytesNum;
const attrSizeBytesNum = uint32BytesNum;
const bufferSizeBytesNum = uint32BytesNum;
const beginRespBytesNum =
    headCodeBytesNum + attrSizeBytesNum + bufferSizeBytesNum;
const headCodePos = 0;
const attrSizePos = headCodePos + headCodeBytesNum;
const bufferSizePos = attrSizePos + attrSizeBytesNum;

class HeadCode {
  static const ok = 0x00;
  static const nok = 0x01;
  static const incorrectFormat = 0x02;
  static const incorrectFirmwareSize = 0x03;
  static const checksumError = 0x04;
  static const internalSrorageError = 0x05;

  static const begin = 0x10;
  static const package = 0x11;
  static const end = 0x12;
}

UploadError determineErrorHeadCode(int code) {
  switch (code) {
    case HeadCode.nok:
      return UploadError.generalDeviceError;
    case HeadCode.incorrectFormat:
      return UploadError.incorrectPackageFormat;
    case HeadCode.incorrectFirmwareSize:
      return UploadError.incorrectFirmwareSize;
    case HeadCode.checksumError:
      return UploadError.incorrectChecksum;
    case HeadCode.internalSrorageError:
      return UploadError.internalSrorageError;
    default:
      return UploadError.unexpectedDeviceResponse;
  }
}
