import 'package:ble_vitals_scanner/features/ble/provider/ble_provider.dart';
import 'package:ble_vitals_scanner/screens/live_data_screen/live_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final String deviceName;
  final String deviceId;

  const DeviceDetailsScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
  });

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late BleProvider _bleProvider;
  bool _startedConnection = false;
  bool _manualDisconnect = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bleProvider = context.read<BleProvider>();

    if (!_startedConnection) {
      _startedConnection = true;

      Future.microtask(() {
        _bleProvider.connectToDevice(widget.deviceId);
      });
    }
  }

  Future<void> _disconnectAndGoToScan() async {
    _manualDisconnect = true;

    await _bleProvider.disconnect();

    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  void dispose() {
    if (!_manualDisconnect) {
      _bleProvider.disconnect();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Device Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [Icon(Icons.more_vert), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.deviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(widget.deviceId, style: const TextStyle(fontSize: 13)),

                const SizedBox(height: 8),

                Text.rich(
                  TextSpan(
                    text: 'Status: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: bleProvider.connectionStatusText,
                        style: TextStyle(
                          color: _getStatusColor(
                            bleProvider.connectionStatusText,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (bleProvider.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    bleProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Services & Characteristics'),

          if (bleProvider.connectionStatusText == 'Connecting')
            const LoadingCard(message: 'Connecting to device...')
          else if (bleProvider.connectionStatusText == 'Disconnecting')
            const LoadingCard(message: 'Disconnecting...')
          else if (bleProvider.isDiscoveringServices)
            const LoadingCard(message: 'Discovering services...')
          else if (bleProvider.connectionStatusText != 'Connected')
            const EmptyStateCard(message: 'Device is not connected yet.')
          else if (bleProvider.services.isEmpty)
            const EmptyStateCard(message: 'No services discovered.')
          else
            ...bleProvider.services.map((service) {
              return ServiceWithCharacteristicsCard(
                service: service,
                deviceId: widget.deviceId,
                deviceName: widget.deviceName,
              );
            }),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: bleProvider.connectionStatusText == 'Disconnecting'
                  ? null
                  : _disconnectAndGoToScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                bleProvider.connectionStatusText == 'Disconnecting'
                    ? 'Disconnecting...'
                    : 'Disconnect',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Connected':
        return Colors.green;
      case 'Connecting':
        return Colors.orange;
      case 'Disconnecting':
        return Colors.orange;
      case 'Disconnected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class InfoCard extends StatelessWidget {
  final Widget child;

  const InfoCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  final String message;

  const LoadingCard({super.key, required this.message});

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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String message;

  const EmptyStateCard({super.key, required this.message});

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
        child: Text(message, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class ServiceWithCharacteristicsCard extends StatelessWidget {
  final DiscoveredService service;
  final String deviceId;
  final String deviceName;

  const ServiceWithCharacteristicsCard({
    super.key,
    required this.service,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    final characteristics = service.characteristics;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service UUID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            SelectableText(
              service.serviceId.toString(),
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 14),

            const Text(
              'Characteristics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (characteristics.isEmpty)
              const Text('No characteristics found')
            else
              ...characteristics.map((characteristic) {
                final canNotify = characteristic.isNotifiable;
                final canRead = characteristic.isReadable;
                final canOpen = canNotify || canRead;

                return CharacteristicItem(
                  characteristic: characteristic,
                  buttonText: canNotify
                      ? 'Subscribe'
                      : canRead
                      ? 'Read'
                      : 'Unavailable',
                  onPressed: canOpen
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveDataScreen(
                                deviceName: deviceName,
                                deviceId: deviceId,
                                serviceId: service.serviceId,
                                characteristicId:
                                    characteristic.characteristicId,
                                isNotifiable: characteristic.isNotifiable,
                              ),
                            ),
                          );
                        }
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class CharacteristicItem extends StatelessWidget {
  final DiscoveredCharacteristic characteristic;
  final String buttonText;
  final VoidCallback? onPressed;

  const CharacteristicItem({
    super.key,
    required this.characteristic,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Characteristic UUID',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                SelectableText(
                  characteristic.characteristicId.toString(),
                  style: const TextStyle(fontSize: 11),
                ),

                const SizedBox(height: 4),

                Text(
                  'Properties: ${_getPropertiesText(characteristic)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }

  String _getPropertiesText(DiscoveredCharacteristic characteristic) {
    final properties = <String>[];

    if (characteristic.isReadable) {
      properties.add('Read');
    }

    if (characteristic.isWritableWithResponse) {
      properties.add('Write');
    }

    if (characteristic.isWritableWithoutResponse) {
      properties.add('Write Without Response');
    }

    if (characteristic.isNotifiable) {
      properties.add('Notify');
    }

    if (characteristic.isIndicatable) {
      properties.add('Indicate');
    }

    if (properties.isEmpty) {
      return 'Unknown';
    }

    return properties.join(', ');
  }
}
