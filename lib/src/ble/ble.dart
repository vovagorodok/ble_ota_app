import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final isSequentialUploadRequired =
    !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
