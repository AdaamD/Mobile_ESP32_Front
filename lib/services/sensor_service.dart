import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart'; // Importez le fichier de configuration
import '../models/sensor_data.dart';

class SensorService {
  Future<SensorData> fetchSensorData() async {
    final response = await http.get(Uri.parse('${AppConfig.apiUrl}/sensors'));

    if (response.statusCode == 200) {
      return SensorData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load sensor data');
    }
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
