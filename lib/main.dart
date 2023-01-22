import 'package:flutter/material.dart';
import 'package:ble_ota_app/src/ui/scaner_screen.dart';

void main() {
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
