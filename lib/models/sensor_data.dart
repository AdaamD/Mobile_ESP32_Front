class SensorData {
  final double temperature;
  final double light;

  SensorData({required this.temperature, required this.light});

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature'].toDouble(),
      light: json['light'].toDouble(),
    );
  }
}
