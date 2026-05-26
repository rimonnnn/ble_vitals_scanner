import 'package:ble_vitals_scanner/screens/scan_screen/scan_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const BleVitalsApp());
}

class BleVitalsApp extends StatelessWidget {
  const BleVitalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Vitals Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const ScanScreen(),
    );
  }
}