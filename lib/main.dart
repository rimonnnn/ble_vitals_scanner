import 'package:ble_vitals_scanner/screens/scan_screen/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/permissions/ble_permission_service.dart';
import 'features/ble/data/ble_repository.dart';
import 'features/ble/provider/ble_provider.dart';


void main() {
  runApp(const BleVitalsApp());
}

class BleVitalsApp extends StatelessWidget {
  const BleVitalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BleProvider(
        bleRepository: BleRepository(),
        permissionService: BlePermissionService(),
      ),
      child: MaterialApp(
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
      ),
    );
  }
}