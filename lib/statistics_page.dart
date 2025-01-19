import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_esp32_application/services/sensor_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'data_list_page.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> _temperatureData = [];
  double _averageTemperature = 0.0;
  double _averageLight = 0.0;
  Timer? _timer;
  final SensorService sensorService = SensorService();
  final TextEditingController _thresholdController = TextEditingController();

  final double minTemperature = 10.0;
  final double maxTemperature = 30.0;

  double minLight = 250.0;
  double maxLight = 800.0;

  Future<void> getLightThreshold() async {
    double lightThreshold = await sensorService.fetchLightThreshold();
    setState(() {
      minLight = lightThreshold * 0.8;
      maxLight = lightThreshold * 1.2;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecentTemperatureData();
    getLightThreshold();
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

        if (_temperatureData.isNotEmpty) {
          double totalTemperature = _temperatureData.fold(
              0, (sum, item) => sum + item['temperature']);
          double totalLight =
              _temperatureData.fold(0, (sum, item) => sum + item['light']);
          _averageTemperature = totalTemperature / _temperatureData.length;
          _averageLight = totalLight / _temperatureData.length;

          if (_averageTemperature < minTemperature ||
              _averageTemperature > maxTemperature) {
            _showAlertDialog('Alerte Température',
                'La température est hors limites : ${_averageTemperature.round()} °C');
          }
          getLightThreshold();
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
    /*
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

    */
  }
  @override
  void dispose() {
    _timer?.cancel();
    _thresholdController.dispose();
    super.dispose();
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  Color getTemperatureColor(double temperature) {
    if (temperature < minTemperature || temperature > maxTemperature) {
      return Colors.red;
    } else if (temperature >= minTemperature && temperature <= maxTemperature) {
      return Colors.green;
    }
    return Colors.yellow;
  }

  Color getLightColor(double light) {
    getLightThreshold();
    if (light < minLight || light > maxLight) {
      return Colors.red;
    } else if (light >= minLight && light <= maxLight) {
      return Colors.green;
    }
    return Colors.yellow;
  }

  Future<void> _updateLightThreshold() async {
    final double newThreshold = double.tryParse(_thresholdController.text) ?? 0;
    if (newThreshold > 0) {
      try {
        await sensorService.updateLightThreshold(newThreshold);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seuil de lumière mis à jour avec succès')),
        );
        print('Seuil de lumière mis à jour avec succès: $newThreshold');
        getLightThreshold();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour du seuil : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valeur de seuil invalide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques'),
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
        child: Padding(
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
                'Mise à jour du seuil de lumière',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nouveau seuil de lumière',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateLightThreshold,
                    child: Text('Mettre à jour'),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DataListPage(_temperatureData)),
                  );
                },
                child: Text('Voir toutes les données collectées'),
              ),
            ],
          ),
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
