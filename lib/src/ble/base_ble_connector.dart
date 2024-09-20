import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

abstract class BaseBleConnector extends BleConnector {
  @override
  BleSerial createSerial(
      String serviceId, String rxCharacteristicId, String txCharacteristicId) {
    return BleSerial(
      characteristicRx: createCharacteristic(serviceId, rxCharacteristicId),
      characteristicTx: createCharacteristic(serviceId, txCharacteristicId),
    );
  }
}
