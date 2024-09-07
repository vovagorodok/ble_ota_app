import 'dart:async';

import 'package:meta/meta.dart';

abstract class StatefulStream<State> extends StateStream<State> {
  State get state;
}

abstract class StateStream<State> {
  final StreamController<State> _stateStreamController =
      StreamController<State>.broadcast();
  Stream<State> get stateStream => _stateStreamController.stream;

  @protected
  void notifyStateUpdate(State state) {
    _stateStreamController.add(state);
  }

  @protected
  bool canNotifyStateUpdate() {
    return !_stateStreamController.isClosed;
  }

  @mustCallSuper
  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}
