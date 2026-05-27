import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../../core/permissions/ble_permission_service.dart';
import '../data/ble_repository.dart';

class BleProvider extends ChangeNotifier {
  final BleRepository _bleRepository;
  final BlePermissionService _permissionService;

  BleProvider({
    required BleRepository bleRepository,
    required BlePermissionService permissionService,
  })  : _bleRepository = bleRepository,
        _permissionService = permissionService;

  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  final List<DiscoveredDevice> _devices = [];

  List<DiscoveredDevice> get devices => _devices;

  bool isScanning = false;
  String? errorMessage;

  Future<void> startScan() async {
    errorMessage = null;

    final hasPermission = await _permissionService.requestPermissions();

    if (!hasPermission) {
      errorMessage = 'Bluetooth permissions are required';
      notifyListeners();
      return;
    }

    _devices.clear();
    isScanning = true;
    notifyListeners();

    _scanSubscription?.cancel();

    _scanSubscription = _bleRepository.scanForDevices().listen(
      (device) {
        final index = _devices.indexWhere((d) => d.id == device.id);

        if (index == -1) {
          _devices.add(device);
        } else {
          _devices[index] = device;
        }

        notifyListeners();
      },
      onError: (error) {
        errorMessage = 'Scan failed: $error';
        isScanning = false;
        notifyListeners();
      },
    );
  }

  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}