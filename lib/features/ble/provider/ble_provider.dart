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
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<List<int>>? _valueSubscription;

  final List<DiscoveredDevice> _devices = [];

  List<DiscoveredDevice> get devices => _devices;

  ConnectionStateUpdate? connectionState;
  String? connectedDeviceId;

  List<DiscoveredService> services = [];

  bool isScanning = false;
  bool isConnecting = false;
  bool isDiscoveringServices = false;
  bool isSubscribing = false;

  String? latestValue;
  final List<String> liveValues = [];

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
        debugPrint(
          'FOUND DEVICE => name: ${device.name}, id: ${device.id}, rssi: ${device.rssi}',
        );

        final index = _devices.indexWhere((d) => d.id == device.id);

        if (index == -1) {
          _devices.add(device);
        } else {
          _devices[index] = device;
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('SCAN ERROR => $error');

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
    latestValue = null;
    liveValues.clear();

    notifyListeners();

    await _connectionSubscription?.cancel();

    _connectionSubscription = _bleRepository.connectToDevice(deviceId).listen(
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

        if (update.connectionState == DeviceConnectionState.disconnecting) {
          isConnecting = false;
        }

        if (update.connectionState == DeviceConnectionState.disconnected) {
          isConnecting = false;
          isDiscoveringServices = false;
          isSubscribing = false;
          services.clear();
          latestValue = null;
          liveValues.clear();

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
        isSubscribing = false;
        services.clear();
        liveValues.clear();
        latestValue = null;
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

  Future<void> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) async {
    try {
      await _valueSubscription?.cancel();

      latestValue = null;
      liveValues.clear();
      isSubscribing = true;
      errorMessage = null;
      notifyListeners();

      debugPrint('Subscribing to characteristic: $characteristicId');

      _valueSubscription = _bleRepository
          .subscribeToCharacteristic(
            deviceId: deviceId,
            serviceId: serviceId,
            characteristicId: characteristicId,
          )
          .listen(
        (data) {
          debugPrint('Received BLE data: $data');

          final parsedValue = _parseBleValue(data);
          latestValue = parsedValue;

          final timestamp = _formatTime(DateTime.now());
          liveValues.insert(0, '$timestamp  →  $parsedValue');

          if (liveValues.length > 20) {
            liveValues.removeLast();
          }

          isSubscribing = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Subscription error: $error');

          isSubscribing = false;
          errorMessage = 'Subscription failed: $error';
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (error) {
      debugPrint('Subscribe failed: $error');

      isSubscribing = false;
      errorMessage = 'Subscribe failed: $error';
      notifyListeners();
    }
  }

  Future<void> readCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) async {
    try {
      await _valueSubscription?.cancel();
      _valueSubscription = null;

      latestValue = null;
      liveValues.clear();
      isSubscribing = false;
      errorMessage = null;
      notifyListeners();

      debugPrint('Reading characteristic: $characteristicId');

      final data = await _bleRepository.readCharacteristic(
        deviceId: deviceId,
        serviceId: serviceId,
        characteristicId: characteristicId,
      );

      debugPrint('Read BLE data: $data');

      final parsedValue = _parseBleValue(data);
      latestValue = parsedValue;

      final timestamp = _formatTime(DateTime.now());
      liveValues.insert(0, '$timestamp  →  $parsedValue');

      notifyListeners();
    } catch (error) {
      debugPrint('Read failed: $error');

      errorMessage = 'Read failed: $error';
      notifyListeners();
    }
  }

  Future<void> stopLiveData() async {
    await _valueSubscription?.cancel();
    _valueSubscription = null;
    isSubscribing = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _valueSubscription?.cancel();
    await _connectionSubscription?.cancel();

    _valueSubscription = null;
    _connectionSubscription = null;

    connectionState = null;
    connectedDeviceId = null;

    services.clear();
    liveValues.clear();

    latestValue = null;

    isConnecting = false;
    isDiscoveringServices = false;
    isSubscribing = false;

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

  String _parseBleValue(List<int> data) {
    if (data.isEmpty) {
      return 'Empty value';
    }

    try {
      final text = String.fromCharCodes(data);

      if (text.trim().isNotEmpty) {
        return text;
      }

      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _valueSubscription?.cancel();
    super.dispose();
  }
}