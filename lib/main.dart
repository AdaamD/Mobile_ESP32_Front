import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'home_page.dart';
import 'colors.dart'; // Importez le fichier colors.dart

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surveillance de Serre',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textTheme: TextTheme(
          titleLarge: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 24),
          bodyMedium: TextStyle(color: AppColors.textColor, fontSize: 16),
        ),
      ),
      home: HomePage(),
    );
  }
}
