import 'package:flutter/material.dart';

class LiveDataScreen extends StatelessWidget {
  final String deviceName;
  final String deviceId;

  const LiveDataScreen({
    super.key,
    required this.deviceName,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final recentValues = [
      {
        'time': '09:30:45 AM',
        'heartRate': '78 bpm',
        'spo2': '97 %',
        'temperature': '36.7 °C',
      },
      {
        'time': '09:30:30 AM',
        'heartRate': '75 bpm',
        'spo2': '97 %',
        'temperature': '36.6 °C',
      },
      {
        'time': '09:30:15 AM',
        'heartRate': '80 bpm',
        'spo2': '98 %',
        'temperature': '36.8 °C',
      },
      {
        'time': '09:30:00 AM',
        'heartRate': '76 bpm',
        'spo2': '97 %',
        'temperature': '36.6 °C',
      },
    ];

    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.white,
        title: const Text(
          'Live Data',
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
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Values',
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
              child: Column(
                children: [
                  ValueRow(label: 'Heart Rate', value: '78 bpm'),
                  SizedBox(height: 18),
                  ValueRow(label: 'SpO2', value: '97 %'),
                  SizedBox(height: 18),
                  ValueRow(label: 'Temperature', value: '36.7 °C'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Values',
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
            child: Column(
              children: recentValues.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(item['time']!),
                      ),
                      Expanded(
                        child: Text(item['heartRate']!),
                      ),
                      Expanded(
                        child: Text(item['spo2']!),
                      ),
                      Expanded(
                        child: Text(item['temperature']!),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

class ValueRow extends StatelessWidget {
  final String label;
  final String value;

  const ValueRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}