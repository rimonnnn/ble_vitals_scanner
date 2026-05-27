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
  }) : _bleRepository = bleRepository,
       _permissionService = permissionService;

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  final List<DiscoveredDevice> _devices = [];

  List<DiscoveredDevice> get devices => _devices;

  ConnectionStateUpdate? connectionState;
  String? connectedDeviceId;

  List<DiscoveredService> services = [];

  bool isScanning = false;
  bool isConnecting = false;
  bool isDiscoveringServices = false;

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

    await _scanSubscription?.cancel();

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

  Future<void> connectToDevice(String deviceId) async {
    errorMessage = null;
    connectedDeviceId = deviceId;
    services.clear();
    connectionState = null;
    isConnecting = true;
    isDiscoveringServices = false;
    notifyListeners();

    await _connectionSubscription?.cancel();

    _connectionSubscription = _bleRepository
        .connectToDevice(deviceId)
        .listen(
          (update) async {
            connectionState = update;

            debugPrint('BLE connection update: ${update.connectionState}');

            if (update.connectionState == DeviceConnectionState.connecting) {
              isConnecting = true;
            }

            if (update.connectionState == DeviceConnectionState.connected) {
              isConnecting = false;
              errorMessage = null;
              notifyListeners();

              await discoverServices(deviceId);
              return;
            }

            if (update.connectionState == DeviceConnectionState.disconnected) {
              isConnecting = false;
              isDiscoveringServices = false;
              services.clear();

              if (connectedDeviceId == deviceId) {
                errorMessage ??= 'Device disconnected';
              }
            }

            notifyListeners();
          },
          onError: (error) {
            debugPrint('BLE connection error: $error');

            isConnecting = false;
            isDiscoveringServices = false;
            services.clear();
            connectedDeviceId = null;
            connectionState = null;
            errorMessage = 'Connection failed: $error';

            notifyListeners();
          },
          cancelOnError: true,
        );
  }

  Future<void> discoverServices(String deviceId) async {
    try {
      isDiscoveringServices = true;
      errorMessage = null;
      notifyListeners();

      services = await _bleRepository.discoverServices(deviceId);

      debugPrint('Discovered services count: ${services.length}');

      isDiscoveringServices = false;
      notifyListeners();
    } catch (error) {
      debugPrint('Discover services error: $error');

      isDiscoveringServices = false;
      services.clear();
      errorMessage = 'Discover services failed: $error';

      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();

    _connectionSubscription = null;
    connectionState = null;
    connectedDeviceId = null;
    services.clear();
    isConnecting = false;
    isDiscoveringServices = false;
    errorMessage = null;

    notifyListeners();
  }

  String get connectionStatusText {
    if (isConnecting) return 'Connecting';

    final state = connectionState?.connectionState;

    if (state == null) return 'Disconnected';

    switch (state) {
      case DeviceConnectionState.connecting:
        return 'Connecting';
      case DeviceConnectionState.connected:
        return 'Connected';
      case DeviceConnectionState.disconnecting:
        return 'Disconnecting';
      case DeviceConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
