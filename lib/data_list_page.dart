import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataListPage extends StatelessWidget {
  final List<Map<String, dynamic>> temperatureData;

  DataListPage(this.temperatureData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des données'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.green[100]!],
          ),
        ),
        child: ListView.builder(
          itemCount: temperatureData.length,
          //reverse: true,
          itemBuilder: (context, index) {
            final data = temperatureData[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.eco,
                    color: Colors.green,
                    size: 30,
                  ),
                  title: Text(
                    formatTimestamp(data['timestamp']),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDataRow(Icons.thermostat, 'Température',
                              '${data['temperature']}°C', Colors.red),
                          SizedBox(height: 10),
                          _buildDataRow(Icons.wb_sunny, 'Lumière',
                              '${data['light']} lux', Colors.orange),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 10),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Spacer(),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }
}
