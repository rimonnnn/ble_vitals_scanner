import 'package:ble_vitals_scanner/screens/device_details_screen/device_details_screen.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = [
      {'name': 'Pulse Oximeter', 'id': 'A4:C1:38:7B:2D:11', 'rssi': '-48 dBm'},
      {'name': 'Heart Sensor', 'id': 'F7:9E:8B:3A:64:2C', 'rssi': '-56 dBm'},
      {'name': 'Unknown Device', 'id': '7C:5D:90:1F:2A:9B', 'rssi': '-72 dBm'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'BLE Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [Icon(Icons.more_vert), SizedBox(width: 8)],
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Scan', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Nearby Devices',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final device = devices[index];

                  return DeviceCard(
                    name: device['name']!,
                    id: device['id']!,
                    rssi: device['rssi']!,
                    onConnect: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeviceDetailsScreen(
                            deviceName: device['name']!,
                            deviceId: device['id']!,
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
                  Text(id),
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
