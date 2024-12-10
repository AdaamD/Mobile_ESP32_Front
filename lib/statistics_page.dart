import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // Valeurs initiales pour simuler les données des capteurs
  double temperature = 22.5;
  double light = 300;

  // Listes pour stocker l'historique des données
  List<double> temperatureHistory = [22.5, 23.0, 23.5, 24.0, 24.5];
  List<double> lightHistory = [300, 320, 340, 360, 380];

  @override
  void initState() {
    super.initState();
    // Les valeurs par défaut sont déjà ajoutées dans les listes ci-dessus
  }

  void _refreshData() {
    setState(() {
      // Incrémenter les valeurs pour simuler le rafraîchissement
      temperature += 1.0;
      light += 10.0;

      // Ajouter les nouvelles valeurs à l'historique
      temperatureHistory.add(temperature);
      lightHistory.add(light);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Données mises à jour')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistiques des Capteurs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Données Actuelles', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Température: ${temperature.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 20)),
            Text('Luminosité: ${light.toStringAsFixed(1)} lux',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            //_buildTemperatureChart(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text('Rafraîchir les Données'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à la page principale
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildTemperatureChart() {
    return Container(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: true),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: temperatureHistory.length > 10
              ? temperatureHistory.length.toDouble() - 1
              : (temperatureHistory.length - 1).toDouble(),
          minY: (temperature - 5)
              .clamp(0, double.infinity), // Ajustez selon vos besoins
          maxY: (temperature + 5).clamp(double.infinity, double.infinity),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                  temperatureHistory.length,
                  (index) =>
                      FlSpot(index.toDouble(), temperatureHistory[index])),
              isCurved: true,
              colors: [Colors.blue],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
  */
}
