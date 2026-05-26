import 'package:ble_vitals_scanner/screens/live_data_screen/live_data_screen.dart';
import 'package:flutter/material.dart';


class DeviceDetailsScreen extends StatelessWidget {
  final String deviceName;
  final String deviceId;

  const DeviceDetailsScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
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
                const SizedBox(height: 6),
                const Text.rich(
                  TextSpan(
                    text: 'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Connected',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Services'),
          const ServiceTile(
            title: 'Heart Rate Service',
            uuid: '0000180D-0000-1000-8000-00805F9B34FB',
          ),
          const ServiceTile(
            title: 'Device Information Service',
            uuid: '0000180A-0000-1000-8000-00805F9B34FB',
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Characteristics'),
          CharacteristicTile(
            title: 'Heart Rate Measurement',
            uuid: '00002A37-0000-1000-8000-00805F9B34FB',
            properties: 'Notify',
            buttonText: 'Subscribe',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveDataScreen(
                    deviceName: deviceName,
                    deviceId: deviceId,
                  ),
                ),
              );
            },
          ),
          CharacteristicTile(
            title: 'Body Sensor Location',
            uuid: '00002A38-0000-1000-8000-00805F9B34FB',
            properties: 'Read',
            buttonText: 'Read',
            onPressed: () {},
          ),
          CharacteristicTile(
            title: 'Battery Level',
            uuid: '00002A19-0000-1000-8000-00805F9B34FB',
            properties: 'Read, Notify',
            buttonText: 'Read',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget child;

  const InfoCard({
    super.key,
    required this.child,
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
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String uuid;

  const ServiceTile({
    super.key,
    required this.title,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'UUID: $uuid',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class CharacteristicTile extends StatelessWidget {
  final String title;
  final String uuid;
  final String properties;
  final String buttonText;
  final VoidCallback onPressed;

  const CharacteristicTile({
    super.key,
    required this.title,
    required this.uuid,
    required this.properties,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
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
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'UUID: $uuid',
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Properties: $properties',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}