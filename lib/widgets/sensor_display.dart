import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../colors.dart';

class SensorDisplay extends StatelessWidget {
  final SensorData sensorData;

  const SensorDisplay({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.secondaryColor,
      child: Container(
        padding: EdgeInsets.all(16), // Padding autour du contenu
        height: 200, // Hauteur réduite pour un aspect plus compact
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.accentColor.withOpacity(0.8),
              AppColors.primaryColor.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // Espacement uniforme entre les éléments
          children: [
            Text(
              'Température',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              '${sensorData.temperature} °C',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            Divider(color: Colors.white70), // Ligne de séparation
            Text(
              'Lumière',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              '${sensorData.light} Lux',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
