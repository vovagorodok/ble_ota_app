import 'package:ble_backend_factory/ble_central.dart';
import 'package:ble_ota_app/src/screens/scanner_screen.dart';
import 'package:ble_ota/ble/uuids.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/material.dart';

void main() async {
  await Settings.init();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('pl', 'PL'),
          Locale('ru', 'RU'),
          Locale('uk', 'UA'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const BleOtaApp()),
  );
}

class BleOtaApp extends StatelessWidget {
  const BleOtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BleOta',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: ScannerScreen(
          bleCentral: bleCentral,
          bleScanner: bleCentral.createScanner(serviceIds: [serviceUuid])),
      debugShowCheckedModeBanner: false,
    );
  }
}
