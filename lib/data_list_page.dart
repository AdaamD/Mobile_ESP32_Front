import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataListPage extends StatelessWidget {
  final List<Map<String, dynamic>> temperatureData;

  DataListPage(this.temperatureData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                    'Historique des données',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                background: Image.asset(
                  'assets/images/semi-greenhouse.png',
                  fit: BoxFit.cover,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(8),
                splashColor: Colors.black12,
                highlightColor: Colors.transparent,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final data = temperatureData[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.eco,
                          color: Color(0xFF4CAF50),
                          size: 30,
                        ),
                        title: Text(
                          formatTimestamp(data['timestamp']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDataRow(Icons.thermostat, 'Température',
                                    '${data['temperature']}°C', Colors.red),
                                const SizedBox(height: 10),
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
                childCount: temperatureData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF388E3C),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }
}
