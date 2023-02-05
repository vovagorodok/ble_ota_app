import 'package:meta/meta.dart';

@immutable
class UploadError {
  const UploadError({
    this.status = UploadErrorStatus.unknown,
    this.code = 0,
  });

  final UploadErrorStatus status;
  final int code;
}

enum UploadErrorStatus {
  unknown,
  generalDeviceError,
  incorrectPackageFormat,
  incorrectFirmwareSize,
  incorrectChecksum,
  internalSrorageError,
  noDeviceResponse,
  unexpectedDeviceResponse,
  unexpectedNetworkResponse,
  generalNetworkError,
}
