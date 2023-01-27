import 'dart:async';

abstract class StatefulStream<T> extends StateStream<T> {
  T get state;
}

abstract class StateStream<T> {
  final StreamController<T> _stateStreamController = StreamController();
  Stream<T> get stateStream => _stateStreamController.stream;

  void addStateToStream(T state) {
    _stateStreamController.add(state);
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}
