import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

abstract class BaseBleCentral extends BleCentral {
  @override
  BleSerial createSerial(String deviceId, String serviceId,
      String rxCharacteristicId, String txCharacteristicId) {
    return BleSerial(
      characteristicRx:
          createCharacteristic(deviceId, serviceId, rxCharacteristicId),
      characteristicTx:
          createCharacteristic(deviceId, serviceId, txCharacteristicId),
    );
  }
}
