import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Importer dart:async pour utiliser Timer

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> _temperatureData = [];
  double _averageTemperature = 0.0;
  double _averageLight = 0.0;
  Timer? _timer; // Déclarez une variable pour le Timer

  // Normes pour la serre
  final double minTemperature = 10.0;
  final double maxTemperature = 30.0;
  final double minLight = 250.0;
  final double maxLight = 800.0;

  @override
  void initState() {
    super.initState();
    _fetchRecentTemperatureData();
    // Démarrez le timer pour actualiser les données toutes les 10 secondes
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _fetchRecentTemperatureData();
    });
  }

  Future<void> _fetchRecentTemperatureData() async {
    final lastTwoMinutes = DateTime.now().subtract(Duration(minutes: 2));

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sensor_data')
          .where('timestamp', isGreaterThan: lastTwoMinutes)
          .orderBy('timestamp')
          .get();

      setState(() {
        _temperatureData = querySnapshot.docs.map((doc) {
          return {
            'temperature': doc['temperature'],
            'light': doc['light'],
            'timestamp': (doc['timestamp'] as Timestamp).toDate(),
          };
        }).toList();

        // Calculer les moyennes
        if (_temperatureData.isNotEmpty) {
          double totalTemperature = _temperatureData.fold(
              0, (sum, item) => sum + item['temperature']);
          double totalLight =
              _temperatureData.fold(0, (sum, item) => sum + item['light']);
          _averageTemperature = totalTemperature / _temperatureData.length;
          _averageLight = totalLight / _temperatureData.length;

          // Vérifiez si les valeurs sont hors limites et affichez une alerte si nécessaire
          if (_averageTemperature < minTemperature ||
              _averageTemperature > maxTemperature) {
            _showAlertDialog('Alerte Température',
                'La température est hors limites : ${_averageTemperature.round()} °C');
          }
          if (_averageLight < minLight || _averageLight > maxLight) {
            _showAlertDialog('Alerte Lumière',
                'La lumière est hors limites : ${_averageLight.round()} lux');
          }
        }
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red), // Icône d'avertissement
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Annulez le timer lorsque le widget est détruit
    super.dispose();
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp); // Format hh:mm
  }

  Color getTemperatureColor(double temperature) {
    if (temperature < minTemperature || temperature > maxTemperature) {
      return Colors.red; // Hors limites
    } else if (temperature >= minTemperature && temperature <= maxTemperature) {
      return Colors.green; // Dans la plage acceptable
    }
    return Colors.yellow; // Proche de la limite (si nécessaire)
  }

  Color getLightColor(double light) {
    if (light < minLight || light > maxLight) {
      return Colors.red; // Hors limites
    } else if (light >= minLight && light <= maxLight) {
      return Colors.green; // Dans la plage acceptable
    }
    return Colors.yellow; // Proche de la limite (si nécessaire)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moyennes des dernières minutes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAverageCard(
                    'Température',
                    '${_averageTemperature.round()} °C',
                    Colors.red,
                    Icons.thermostat),
                _buildAverageCard('Lumière', '${_averageLight.round()} lux',
                    Colors.blue, Icons.wb_sunny),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Visualisation des Valeurs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                Text(
                    'Température actuelle : ${_averageTemperature.toStringAsFixed(1)} °C'),
                LinearProgressIndicator(
                  value: (_averageTemperature - minTemperature) /
                      (maxTemperature - minTemperature),
                  backgroundColor: Colors.grey[300],
                  color: getTemperatureColor(_averageTemperature),
                ),
                SizedBox(height: 20),
                Text(
                    'Lumière actuelle : ${_averageLight.toStringAsFixed(1)} lux'),
                LinearProgressIndicator(
                  value: (_averageLight - minLight) / (maxLight - minLight),
                  backgroundColor: Colors.grey[300],
                  color: getLightColor(_averageLight),
                ),
              ],
            ),
            SizedBox(height: 50), // Ajout d'un espacement supplémentaire
            Text(
              'Données Collectées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5), // Réduction de l'espacement ici
            Expanded(
              child: ListView.builder(
                itemCount: _temperatureData.length,
                itemBuilder: (context, index) {
                  final data = _temperatureData[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.data_usage, color: Colors.green),
                      title: Text('Température : ${data['temperature']} °C'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lumière : ${data['light']} lux'),
                          Text(
                              'Timestamp : ${formatTimestamp(data['timestamp'])}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 8),
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
