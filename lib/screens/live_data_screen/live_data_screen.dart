import 'package:ble_vitals_scanner/features/ble/provider/ble_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class LiveDataScreen extends StatefulWidget {
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
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = context.read<BleProvider>();

      if (widget.isNotifiable) {
        provider.subscribeToCharacteristic(
          deviceId: widget.deviceId,
          serviceId: widget.serviceId,
          characteristicId: widget.characteristicId,
        );
      } else {
        provider.readCharacteristic(
          deviceId: widget.deviceId,
          serviceId: widget.serviceId,
          characteristicId: widget.characteristicId,
        );
      }
    });
  }

  @override
  void dispose() {
    context.read<BleProvider>().stopLiveData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Live Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeviceInfoCard(
            deviceName: widget.deviceName,
            deviceId: widget.deviceId,
            serviceId: widget.serviceId,
            characteristicId: widget.characteristicId,
            mode: widget.isNotifiable ? 'Subscribe' : 'Read',
          ),

          const SizedBox(height: 24),

          const Text(
            'Current Value',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: bleProvider.isSubscribing
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Waiting for live value...'),
                      ],
                    )
                  : Text(
                      bleProvider.latestValue ?? 'No value received yet',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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

          const SizedBox(height: 24),

          const Text(
            'Recent Values',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: bleProvider.liveValues.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No recent values yet'),
                  )
                : Column(
                    children: bleProvider.liveValues.map((value) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Text(value),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isNotifiable
                  ? () {
                      context.read<BleProvider>().stopLiveData();
                    }
                  : () {
                      context.read<BleProvider>().readCharacteristic(
                        deviceId: widget.deviceId,
                        serviceId: widget.serviceId,
                        characteristicId: widget.characteristicId,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isNotifiable
                    ? Colors.orange
                    : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                widget.isNotifiable ? 'Stop Live Stream' : 'Read Again',
              ),
            ),
          ),

          const SizedBox(height: 12),

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
              child: const Text('Disconnect', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final Uuid serviceId;
  final Uuid characteristicId;
  final String mode;

  const _DeviceInfoCard({
    required this.deviceName,
    required this.deviceId,
    required this.serviceId,
    required this.characteristicId,
    required this.mode,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(deviceId, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 14),

            const Text(
              'Service UUID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            SelectableText(
              serviceId.toString(),
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 12),

            const Text(
              'Characteristic UUID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            SelectableText(
              characteristicId.toString(),
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 12),

            Text(
              'Mode: $mode',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
