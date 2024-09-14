import 'dart:async';

import 'package:meta/meta.dart';

abstract class DataNotifier<Data> {
  final StreamController<Data> _dataStreamController =
      StreamController<Data>.broadcast();
  Stream<Data> get dataStream => _dataStreamController.stream;

  @protected
  void notifyData(Data data) {
    if (canNotifyData()) _dataStreamController.add(data);
  }

  @protected
  bool canNotifyData() {
    return !_dataStreamController.isClosed;
  }

  @mustCallSuper
  void dispose() {
    _dataStreamController.close();
  }
}
