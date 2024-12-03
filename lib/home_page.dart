import 'package:flutter/material.dart';
import 'widgets/sensor_display.dart';
import 'widgets/led_control.dart';
import 'models/sensor_data.dart';
import '../colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Importation du service API
import 'services/sensor_service.dart'; // Assurez-vous que ce chemin est correct

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SensorData sensorData = SensorData(temperature: 22.5, light: 300);
  final SensorService sensorService =
      SensorService(); // Instance du service API

  @override
  void initState() {
    super.initState();
    // fetchSensorData(); // Décommenter pour récupérer les données de l'API
  }

  Future<void> fetchSensorData() async {
    try {
      // Récupération des données de l'API
      SensorData data = await sensorService.fetchSensorData();
      setState(() {
        sensorData = data; // Mise à jour des données avec celles récupérées
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      // Gestion des erreurs ici (afficher un message, etc.)
    }
  }

  void controlLED(String state) {
    print('LED $state');
    setState(() {
      sensorData = SensorData(
        temperature: sensorData.temperature + (state == 'on' ? 1 : -1),
        light: sensorData.light,
      );
    });
  }

  void sendMessage(String message) {
    print('Message envoyé: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  SensorDisplay(sensorData: sensorData), // Affichage du cadran
            ),
            SizedBox(height: 400), // Espace entre le cadran et les contrôles
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: AppColors.secondaryColor.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Contrôle de la LED',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            SvgPicture.asset('assets/images/lightbulb_on.svg',
                                height: 50),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => controlLED('on'),
                              child: Text('Allumer LED'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentColor),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SvgPicture.asset('assets/images/lightbulb_off.svg',
                                height: 50),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => controlLED('off'),
                              child: Text('Éteindre LED'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Entrez un message',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.accentColor)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.accentColor)),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => sendMessage(
                          'Votre message ici'), // Remplacez par la logique d'envoi
                      child: Text('Envoyer Message'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.accentColor), // Couleur du bouton
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
