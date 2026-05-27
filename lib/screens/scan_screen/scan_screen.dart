import 'package:ble_vitals_scanner/features/ble/provider/ble_provider.dart';
import 'package:ble_vitals_scanner/screens/device_details_screen/device_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  String _deviceName(DiscoveredDevice device) {
    if (device.name.trim().isEmpty) {
      return 'Unknown Device';
    }
    return device.name;
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BLE Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                text: 'Bluetooth: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'ON',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: bleProvider.isScanning
                    ? bleProvider.stopScan
                    : bleProvider.startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bleProvider.isScanning
                      ? Colors.red
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  bleProvider.isScanning ? 'Stop Scan' : 'Start Scan',
                ),
              ),
            ),

            if (bleProvider.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                bleProvider.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Devices',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                if (bleProvider.isScanning)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: bleProvider.devices.isEmpty
                  ? Center(
                      child: Text(
                        bleProvider.isScanning
                            ? 'Scanning for BLE devices...'
                            : 'Press Start Scan to discover devices',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: bleProvider.devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final device = bleProvider.devices[index];

                        return DeviceCard(
                          name: _deviceName(device),
                          id: device.id,
                          rssi: '${device.rssi} dBm',
                          onConnect: () async {
                            await bleProvider.stopScan();

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeviceDetailsScreen(
                                  deviceName: _deviceName(device),
                                  deviceId: device.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final String name;
  final String id;
  final String rssi;
  final VoidCallback onConnect;

  const DeviceCard({
    super.key,
    required this.name,
    required this.id,
    required this.rssi,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(id, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('RSSI: $rssi'),
                ],
              ),
            ),
            OutlinedButton(onPressed: onConnect, child: const Text('Connect')),
          ],
        ),
      ),
    );
  }
}
