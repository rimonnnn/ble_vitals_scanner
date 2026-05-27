import 'package:ble_vitals_scanner/features/ble/provider/ble_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class LiveDataScreen extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final Uuid serviceId;
  final Uuid characteristicId;
  final bool isNotifiable;

  const LiveDataScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.serviceId,
    required this.characteristicId,
    required this.isNotifiable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(deviceId),
                  const SizedBox(height: 12),
                  const Text(
                    'Service UUID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceId.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Characteristic UUID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    characteristicId.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isNotifiable ? 'Mode: Subscribe' : 'Mode: Read',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Current Value',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Live value will appear here in the next step.',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await context.read<BleProvider>().disconnect();

                if (!context.mounted) return;

                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Disconnect',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}