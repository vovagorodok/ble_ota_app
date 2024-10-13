enum UploadError {
  unknown,
  generalDeviceError,
  incorrectPackageFormat,
  incorrectFirmwareSize,
  incorrectChecksum,
  internalSrorageError,
  uploadDisabled,
  noDeviceResponse,
  unexpectedDeviceResponse,
  unexpectedNetworkResponse,
  generalNetworkError,
}

enum InfoError {
  unknown,
  incorrectFileFormat,
  unexpectedNetworkResponse,
  generalNetworkError,
}

enum PinChangeError {
  unknown,
  generalDeviceError,
  noDeviceResponse,
  unexpectedDeviceResponse,
}
