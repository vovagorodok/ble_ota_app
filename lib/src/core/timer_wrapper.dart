import 'dart:async';

class TimerWrapper {
  Timer? _handle;

  void start(Duration duration, void Function() callback) {
    stop();
    _handle = Timer(duration, callback);
  }

  void stop() {
    if (isActive()) {
      _handle!.cancel();
      _handle = null;
    }
  }

  bool isActive() {
    return _handle != null;
  }
}
