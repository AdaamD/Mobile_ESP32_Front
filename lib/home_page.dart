import 'package:flutter/material.dart';
import 'widgets/sensor_display.dart';
import 'widgets/led_control.dart';
import 'models/sensor_data.dart';
import '../colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/sensor_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SensorService sensorService = SensorService();
  Future<SensorData>? _sensorDataFuture;
  bool useStaticData = true; // Mettre à false pour utiliser l'API

  @override
  void initState() {
    super.initState();
    _refreshSensorData();
  }

  Future<void> _refreshSensorData() async {
    setState(() {
      if (useStaticData) {
        _sensorDataFuture =
            Future.value(SensorData(temperature: 22.5, light: 300));
      } else {
        _sensorDataFuture = sensorService.fetchSensorData();
      }
      // Uncomment to use API
      // _sensorDataFuture = sensorService.fetchSensorData();
    });
  }

  Future<void> controlLED(String state) async {
    try {
      await sensorService.controlLED(state);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LED $state avec succès')),
      );
      _refreshSensorData(); // Rafraîchir les données après le changement
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du contrôle de la LED: $e')),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      await sensorService.sendMessage(message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message envoyé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSensorData,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Surveillance de Serre',
                  style: TextStyle(
                    color: const Color.fromARGB(236, 255, 255, 255),
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                background: Image.asset(
                  'assets/images/semi-greenhouse.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSensorDataCard(),
                    SizedBox(height: 20),
                    _buildLEDControlCard(),
                    SizedBox(height: 20),
                    _buildMessageCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDataCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Données du capteur',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            FutureBuilder<SensorData>(
              future: useStaticData
                  ? Future.value(SensorData(temperature: 22.5, light: 300))
                  : _sensorDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSensorInfo(Icons.thermostat,
                          '${snapshot.data!.temperature}°C', 'Température'),
                      _buildSensorInfo(Icons.wb_sunny,
                          '${snapshot.data!.light} lux', 'Luminosité'),
                    ],
                  );
                } else {
                  return Text('Aucune donnée disponible');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppColors.accentColor),
        Text(value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  Widget _buildLEDControlCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Contrôle de la LED',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLEDControl('On', Icons.lightbulb, () => controlLED('on'),
                    Colors.yellow),
                _buildLEDControl('Off', Icons.lightbulb_outline,
                    () => controlLED('off'), Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLEDControl(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Icon(icon, size: 30),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: color,
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildMessageCard() {
    final TextEditingController _messageController = TextEditingController();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Envoyer un message',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Entrez un message',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentColor)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentColor)),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  sendMessage(_messageController.text);
                  _messageController.clear();
                }
              },
              child: Text('Envoyer Message'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
