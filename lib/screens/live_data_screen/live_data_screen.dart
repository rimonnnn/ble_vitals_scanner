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
  late BleProvider _bleProvider;

  bool _started = false;
  bool _isStreamStopped = false;
  bool _manualDisconnect = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bleProvider = context.read<BleProvider>();

    if (!_started) {
      _started = true;
      _startLiveData();
    }
  }

  void _startLiveData() {
    setState(() {
      _isStreamStopped = false;
    });

    if (widget.isNotifiable) {
      _bleProvider.subscribeToCharacteristic(
        deviceId: widget.deviceId,
        serviceId: widget.serviceId,
        characteristicId: widget.characteristicId,
      );
    } else {
      _bleProvider.readCharacteristic(
        deviceId: widget.deviceId,
        serviceId: widget.serviceId,
        characteristicId: widget.characteristicId,
      );
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
      _bleProvider.stopLiveData();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();

    final isDisconnecting = bleProvider.connectionStatusText == 'Disconnecting';

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
              onPressed: isDisconnecting
                  ? null
                  : widget.isNotifiable
                      ? () async {
                          if (_isStreamStopped) {
                            _startLiveData();
                          } else {
                            await _bleProvider.stopLiveData();

                            if (!mounted) return;

                            setState(() {
                              _isStreamStopped = true;
                            });
                          }
                        }
                      : () {
                          _bleProvider.readCharacteristic(
                            deviceId: widget.deviceId,
                            serviceId: widget.serviceId,
                            characteristicId: widget.characteristicId,
                          );
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isNotifiable
                    ? (_isStreamStopped ? Colors.blue : Colors.orange)
                    : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                widget.isNotifiable
                    ? (_isStreamStopped
                        ? 'Restart Live Stream'
                        : 'Stop Live Stream')
                    : 'Read Again',
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isDisconnecting ? null : _disconnectAndGoToScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isDisconnecting ? 'Disconnecting...' : 'Disconnect',
                style: const TextStyle(fontSize: 16),
              ),
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