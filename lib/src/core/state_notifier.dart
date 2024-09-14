import 'dart:async';

import 'package:meta/meta.dart';

abstract class StatefulNotifier<State> extends StateNotifier<State> {
  State get state;
}

abstract class StateNotifier<State> {
  final StreamController<State> _stateStreamController =
      StreamController<State>.broadcast();
  Stream<State> get stateStream => _stateStreamController.stream;

  @protected
  void notifyState(State state) {
    if (canNotifyState()) _stateStreamController.add(state);
  }

  @protected
  bool canNotifyState() {
    return !_stateStreamController.isClosed;
  }

  @mustCallSuper
  void dispose() {
    _stateStreamController.close();
  }
}
