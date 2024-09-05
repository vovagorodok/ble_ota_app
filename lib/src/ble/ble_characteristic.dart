import 'dart:async';

abstract class BleCharacteristic {
  Future<List<int>> read();
  Future<void> write(List<int> data);
  Future<void> writeWithoutResponse(List<int> data);
  void subscribe({required void Function(List<int>) onData});
  void unsubscribe();
  void dispose();
}
