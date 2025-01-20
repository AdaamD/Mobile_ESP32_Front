import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_esp32_application/services/sensor_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'data_list_page.dart';
import 'colors.dart';

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

// Seuils de température et de lumière
  final double minTemperature = 5.0;
  final double maxTemperature = 30.0;
  final double optimalMinTemperature = 10.0;
  final double optimalMaxTemperature = 20.0;

  double lightThreshold = 500.0; // Valeur par défaut
  double minLight = 0.0;
  double maxLight = 1000.0;
  double optimalMinLight = 0.0;
  double optimalMaxLight = 1000.0;

  // Récupère le seuil de lumière depuis Firestore
  Future<void> getLightThreshold() async {
    double fetchedThreshold = await sensorService.fetchLightThreshold();
    setState(() {
      lightThreshold = fetchedThreshold;
      minLight = lightThreshold * 0.5; // 50% en dessous du seuil
      maxLight = lightThreshold * 1.5; // 50% au-dessus du seuil
      optimalMinLight = lightThreshold * 0.9; // 10% en dessous du seuil
      optimalMaxLight = lightThreshold * 1.1; // 10% au-dessus du seuil
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecentTemperatureData();
    getLightThreshold();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
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

          // Vérification de la température
          if (_averageTemperature < minTemperature ||
              _averageTemperature > maxTemperature) {
            _showAlertDialog('Alerte Température',
                'La température est hors limites : ${_averageTemperature.round()} °C');
          } else if (_averageTemperature < optimalMinTemperature ||
              _averageTemperature > optimalMaxTemperature) {
            _showAlertDialog('Avertissement Température',
                'La température n\'est pas optimale : ${_averageTemperature.round()} °C');
          }

          // Mise à jour et vérification du seuil de lumière
          getLightThreshold().then((_) {
            if (_averageLight < minLight || _averageLight > maxLight) {
              _showAlertDialog('Alerte Lumière',
                  'La lumière est hors limites : ${_averageLight.round()} lux');
            } else if (_averageLight < optimalMinLight ||
                _averageLight > optimalMaxLight) {
              _showAlertDialog('Avertissement Lumière',
                  'La lumière n\'est pas optimale : ${_averageLight.round()} lux');
            }
          });
        }
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
    }
  }

  // Couleur de la température en fonction de la plage de température
  Color getTemperatureColor(double temperature) {
    if (temperature < optimalMinTemperature) {
      return Colors.yellow; // Trop froid
    } else if (temperature > optimalMaxTemperature) {
      return Colors.red; // Trop chaud
    } else {
      return Colors.green; // Température optimale
    }
  }

// Couleur de la lumière en fonction de la plage de lumière
  Color getLightColor(double light) {
    if (light < optimalMinLight) {
      return Colors.yellow; // Trop sombre
    } else if (light > optimalMaxLight) {
      return Colors.red; // Trop lumineux
    } else {
      return Colors.green; // Lumière optimale
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, // Padding de 10 pixels à gauche et à droite
                ),
                child: Text(
                  'Vue Statistique',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              background: Image.asset(
                'assets/images/semi-greenhouse.png',
                fit: BoxFit.cover,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(
                  8), // Ajouter un padding pour donner plus d'espace autour de l'icône
              splashColor: Colors.black12, // Couleur de l'effet de splash
              highlightColor: Colors
                  .transparent, // Supprimer l'effet de surbrillance par défaut
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  color: AppColors.backgroundColor, // Fond de la page
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAverageCard(
                              title: 'Température',
                              value: '${_averageTemperature.round()} °C',
                              color: Colors.redAccent.shade200,
                              icon: Icons.thermostat,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildAverageCard(
                              title: 'Lumière',
                              value: '${_averageLight.round()} lux',
                              color: Colors.amber.shade600,
                              icon: Icons.wb_sunny,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Visualisation des valeurs
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Visualisation des Valeurs',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildProgressIndicatorWithLabel(
                              label: 'Température actuelle',
                              value: _averageTemperature,
                              min: minTemperature,
                              max: maxTemperature,
                              color: getTemperatureColor(_averageTemperature),
                            ),
                            const SizedBox(height: 30),
                            _buildProgressIndicatorWithLabel(
                              label: 'Lumière actuelle',
                              value: _averageLight,
                              min: minLight,
                              max: maxLight,
                              color: getLightColor(_averageLight),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildThresholdUpdateSection(),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DataListPage(_temperatureData),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.storage_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Voir toutes les données',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            textStyle: const TextStyle(fontSize: 18),
                            backgroundColor: AppColors.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            shadowColor: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Paramètres pour la carte de statistiques
  Widget _buildAverageCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 6, // Augmentation de l'élévation pour un effet plus marqué
      shadowColor: Colors.black26, // Couleur de l'ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Coins arrondis
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.black.withOpacity(0.2), // Bordure noire très fine
            width: 1, // Très fine
          ),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1), // Couleur principale atténuée
              color.withOpacity(0.05), // Couleur plus douce
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2), // Fond léger pour l'icône
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  size: 50,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentColor, // Accent contrastant
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Crée un indicateur de progression avec une étiquette
  Widget _buildProgressIndicatorWithLabel({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
  }) {
    // Ajout des unités statiques pour les labels spécifiques
    String unit = '';
    if (label.contains('Température')) {
      unit = '°C';
    } else if (label.contains('Lumière')) {
      unit = 'lux';
    }

    return Container(
      padding: const EdgeInsets.all(16), // Espacement interne
      decoration: BoxDecoration(
        color: Colors.white
            .withOpacity(0.85), // Fond blanc cassé légèrement transparent
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Ombre douce et subtile
            blurRadius: 12, // Flou légèrement plus grand
            offset: const Offset(0, 6), // Décalage pour un effet plus dynamique
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0), // Couleur contrastée
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '${value.toStringAsFixed(1)} $unit', // Affiche la valeur avec l'unité appropriée
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8), // Espacement réduit entre texte et barre
          ClipRRect(
            borderRadius:
                BorderRadius.circular(6), // Arrondi du fond de la barre
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withOpacity(
                      0.2), // Subtilement assorti à la couleur principale
                  width: 1, // Largeur de la bordure
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LinearProgressIndicator(
                value: (value - min) / (max - min),
                backgroundColor: Colors.grey[300], // Fond de la barre
                color: color, // Couleur principale
                minHeight:
                    16, // Hauteur plus grande pour une meilleure visibilité
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdUpdateSection() {
    return Card(
      elevation: 4, // Ajoute une légère ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec icône, taille et style améliorés
            Row(
              children: [
                Icon(Icons.tune,
                    color: AppColors.accentColor,
                    size: 32), // Icône plus grande
                const SizedBox(width: 10),
                Text(
                  'Mettre à jour le seuil',
                  style: TextStyle(
                    fontSize:
                        26, // Augmente la taille du texte pour une meilleure visibilité
                    fontWeight: FontWeight
                        .w600, // Rendre le texte plus audacieux mais sans trop d'ombre
                    color: AppColors.accentColor,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2.0, // Ombre plus légère
                        color:
                            Color.fromARGB(100, 0, 0, 0), // Ombre plus subtile
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Champ de texte avec bords arrondis et ombrage doux
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal:
                        20), // Ajout de padding interne pour plus de confort
                prefixIcon: const Icon(Icons.edit,
                    color: AppColors.accentColor,
                    size: 24), // Icône plus grande
                hintText: 'Nouvelle valeur',
                hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold), // Police plus grasse
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Bords arrondis
                  borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 1), // Bordure plus douce
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      15), // Bords arrondis aussi quand focus
                  borderSide: BorderSide(
                      color: AppColors.accentColor, width: 2), // Bordure focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      15), // Bords arrondis également pour état désactivé
                  borderSide: BorderSide(
                      color: AppColors.accentColor.withOpacity(0.4), width: 1),
                ),
                filled: true,
                fillColor: Colors.white
                    .withOpacity(0.7), // Remplissage de fond légèrement blanc
              ),
            ),
            const SizedBox(height: 20),

            // Bouton pour appliquer la mise à jour
            ElevatedButton(
              onPressed: _updateLightThreshold,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold), // Bouton plus gras
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}
