import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart'; // Importez le fichier de configuration
import '../models/sensor_data.dart';

class SensorService {
  double _lightThreshold = 1000.0; // Valeur par défaut

// Acutalise les données des capteurs
  Future<SensorData> fetchSensorData() async {
    final response = await http.get(Uri.parse('${AppConfig.apiUrl}/sensors'));

    if (response.statusCode == 200) {
      final data = SensorData.fromJson(json.decode(response.body));
      await storeSensorDataInFirestore(data);
      return data;
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

// Stocke les données des capteurs dans Firestore
  Future<void> storeSensorDataInFirestore(SensorData data) async {
    try {
      await FirebaseFirestore.instance.collection('sensor_data').add({
        'temperature': data.temperature,
        'light': data.light,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors du stockage des données dans Firestore : $e');
    }
  }

//Test firebase connection
  Future<bool> testFirestoreConnection() async {
    try {
      // Écriture d'un document test
      await FirebaseFirestore.instance.collection('test').add({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Test de connectivité'
      });

      // Lecture du document test
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('test')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Test Firestore réussi : ${querySnapshot.docs.first.data()}');
        return true;
      } else {
        print('Test Firestore échoué : Aucun document trouvé');
        return false;
      }
    } catch (e) {
      print('Erreur lors du test Firestore : $e');
      return false;
    }
  }

  // Requete pour changer le seuil de luminosité
  Future<void> updateLightThreshold(double newThreshold) async {
    final url = Uri.parse('${AppConfig.apiUrl}/updateThreshold');
    try {
      final response = await http.post(
        url,
        body: {'threshold': newThreshold.toString()},
      );
      if (response.statusCode == 200) {
        _lightThreshold = newThreshold; // Mettre à jour le seuil en mémoire
      } else {
        throw Exception(
            'Erreur lors de la mise à jour du seuil : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  // Obtenir le seuil de luminosité actuel
  Future<double> fetchLightThreshold() async {
    final response = await http.get(Uri.parse('${AppConfig.apiUrl}/threshold'));
    if (response.statusCode == 200) {
      print('Light threshold: $_lightThreshold');
      return double.parse(response.body);
    } else {
      throw Exception('Failed to fetch light threshold');
    }
  }

  double getLightThreshold() {
    return _lightThreshold;
  }

  Future<void> controlLED(String state) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/led'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'state': state}, // Utilisez un Map pour x-www-form-urlencoded
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to control LED: ${response.body}');
    }
  }

  Future<void> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/post?message=$message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
