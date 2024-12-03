import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/sensor_data.dart';

class SensorService {
  Future<SensorData> fetchSensorData() async {
    final response =
        await http.get(Uri.parse('${AppConfig.apiBaseUrl}/sensors'));

    if (response.statusCode == 200) {
      return SensorData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  Future<void> controlLED(String state) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/led'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'state': state}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to control LED');
    }
  }

  Future<void> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/post'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
