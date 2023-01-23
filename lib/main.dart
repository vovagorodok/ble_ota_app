import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ble_ota_app/src/ui/scaner_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.blue,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ble Ota',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const ScanerScreen(),
    );
  }
}
