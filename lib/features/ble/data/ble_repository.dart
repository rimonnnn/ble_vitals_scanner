import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleRepository {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  Stream<BleStatus> get bleStatusStream => _ble.statusStream;

  Stream<DiscoveredDevice> scanForDevices() {
    return _ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency);
  }

  Stream<ConnectionStateUpdate> connectToDevice(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    );
  }

  Future<List<DiscoveredService>> discoverServices(String deviceId) {
    return _ble.discoverServices(deviceId);
  }

  Stream<List<int>> subscribeToCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) {
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: serviceId,
      characteristicId: characteristicId,
    );

    return _ble.subscribeToCharacteristic(characteristic);
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
  }) {
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: serviceId,
      characteristicId: characteristicId,
    );

    return _ble.readCharacteristic(characteristic);
  }

  Future<void> writeCharacteristicWithoutResponse({
    required String deviceId,
    required Uuid serviceId,
    required Uuid characteristicId,
    required List<int> value,
  }) {
    final characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: serviceId,
      characteristicId: characteristicId,
    );

    return _ble.writeCharacteristicWithoutResponse(
      characteristic,
      value: value,
    );
  }
}
