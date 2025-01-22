import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'widgets/sensor_display.dart';
//import 'widgets/led_control.dart';
import 'models/sensor_data.dart';
import 'statistics_page.dart';
import '../colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/sensor_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SensorService sensorService = SensorService();
  late Future<SensorData> _sensorDataFuture;
  Timer? _timer; // Déclarez une variable pour le Timer

  @override
  void initState() {
    super.initState();
    _sensorDataFuture = _refreshSensorData();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      setState(() {
        _sensorDataFuture = _refreshSensorData();
      });
    });
  }

// Fonction pour rafraîchir les données du capteur
  Future<SensorData> _refreshSensorData() async {
    try {
      return await sensorService.fetchSensorData();
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      throw e; // Propager l'erreur pour qu'elle soit gérée par le FutureBuilder
    }
  }

// Annulez le Timer lorsque l'état est détruit
  @override
  void dispose() {
    _timer?.cancel(); // Annulez le Timer lorsque l'état est détruit
    super.dispose();
  }

// Fonction pour contrôler la LED
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

  // Fonction pour envoyer un message
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
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0, // Padding de 16 pixels en haut et en bas
                    horizontal:
                        10.0, // Padding de 8 pixels à gauche et à droite
                  ),
                  child: Text(
                    'eSerrePortal ',
                    style: TextStyle(
                      fontSize: 35, // Taille du texte
                      fontWeight: FontWeight.bold, // Gras pour le titre
                      color: const Color.fromARGB(
                          236, 255, 255, 255), // Couleur du texte
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(150, 0, 0, 0), // Ombre subtile
                        ),
                      ],
                    ),
                  ),
                ),
                background: Image.asset(
                  'assets/images/semi-greenhouse.png', // Image de fond
                  fit: BoxFit.cover, // Couvre toute la surface de l'AppBar
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
                    SizedBox(height: 20),

                    // Bouton Accéder aux Statistiques Détaillées
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StatisticsPage()),
                        );
                      },
                      icon: Icon(Icons.bar_chart, color: Colors.white),
                      label: Text('Accéder aux Statistiques Détaillées'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Couleur plus douce
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Ajout d'un espace entre les boutons

                    // Bouton Test Connexion Firestore
                    ElevatedButton.icon(
                      onPressed: () async {
                        bool isConnected =
                            await sensorService.testFirestoreConnection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isConnected
                                ? 'Connecté à Firestore'
                                : 'Échec de connexion à Firestore'),
                          ),
                        );
                      },
                      icon: Icon(Icons.cloud_done, color: Colors.white),
                      label: Text('Tester la Connexion Firestore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Couleur plus douce
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// Widget pour afficher les données du capteur
  Widget _buildSensorDataCard() {
    return Card(
      elevation: 8, // Un peu plus d'élévation pour plus de relief
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            16), // Bords arrondis pour un effet plus moderne
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Données du capteur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors
                    .black54, // Utilisation de la couleur teal pour plus de vivacité
                letterSpacing: 1.2, // Espacement des lettres pour un effet aéré
                shadows: [
                  Shadow(
                    offset: Offset(2, 2), // Ombre plus marquée pour le titre
                    blurRadius: 6,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            FutureBuilder<SensorData>(
              future: _sensorDataFuture, // Utilisation des données récupérées
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: TextStyle(
                        color: Colors.redAccent, // Couleur d'erreur plus vive
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSensorInfo(
                        Icons.thermostat,
                        '${snapshot.data!.temperature}°C',
                        'Température',
                        textColor: Colors.redAccent
                            .shade200, // Température avec une couleur chaude
                      ),
                      _buildSensorInfo(
                        Icons.wb_sunny,
                        '${snapshot.data!.light} lux',
                        'Luminosité',
                        textColor: Colors.amber
                            .shade600, // Luminosité avec une couleur lumineuse
                      ),
                    ],
                  );
                } else {
                  return Text(
                    'Aucune donnée disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey, // Texte gris pour absence de données
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// Widget pour afficher les informations du capteur
  Widget _buildSensorInfo(IconData icon, String value, String label,
      {Color? textColor}) {
    return Column(
      children: [
        Icon(
          icon,
          color: textColor ??
              Colors.blueGrey, // Couleur de l'icône ajustée dynamiquement
          size: 36,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor ??
                Colors.black87, // Couleur dynamique pour les valeurs
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black54, // Couleur pour l'étiquette
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

// Widget pour contrôler la LED
  Widget _buildLEDControlCard() {
    return Card(
      elevation: 8, // Plus d'élévation pour ajouter du relief
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bords arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Contrôle de la LED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 6,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLEDControl(
                  'On',
                  Icons.lightbulb,
                  () => controlLED('on'),
                  Colors.yellow,
                  labelColor: Colors
                      .black87, // Texte de l'étiquette plus foncé pour un meilleur contraste
                ),
                _buildLEDControl(
                  'Off',
                  Icons.lightbulb_outline,
                  () => controlLED('off'),
                  Colors.grey,
                  labelColor: Colors.black54, // Texte de l'étiquette plus doux
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Widget pour contrôler la LED
  Widget _buildLEDControl(
      String label, IconData icon, VoidCallback onPressed, Color iconColor,
      {Color? labelColor}) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Forme circulaire
              color: iconColor.withOpacity(0.2), // Opacité pour un effet doux
            ),
            padding:
                const EdgeInsets.all(16), // Espacement pour agrandir l'icône
            child: Icon(
              icon,
              color: iconColor,
              size: 36, // Taille plus grande pour les icônes
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: labelColor ??
                  Colors.black87, // Couleur dynamique de l'étiquette
              fontStyle: FontStyle.italic, // Italique pour un effet visuel
            ),
          ),
        ],
      ),
    );
  }

// Widget pour envoyer un message
  Widget _buildMessageCard() {
    final TextEditingController _messageController = TextEditingController();

    return Card(
      elevation: 2, // Légère élévation pour un effet doux
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Coins arrondis
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre avec style simple et épuré
            Text(
              'Envoyer un message',
              style: TextStyle(
                fontSize: 22, // Taille plus grande pour le titre
                fontWeight: FontWeight
                    .w600, // Poids moyen pour éviter un aspect trop lourd
                color: Colors.black87, // Couleur subtile mais lisible
              ),
            ),
            SizedBox(height: 16),

            // Champ de texte épuré avec bordures fines et couleurs neutres
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Entrez un message',
                labelStyle:
                    TextStyle(color: Colors.black54), // Label gris neutre
                prefixIcon: Icon(Icons.message,
                    color: Colors.black54), // Icône simple, gris
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[500]!, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              style: TextStyle(
                  fontSize: 16, color: Colors.black), // Texte simple et lisible
            ),
            SizedBox(height: 16),

            // Bouton avec un design épuré
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  sendMessage(_messageController.text);
                  _messageController.clear();
                }
              },
              child: Text(
                'Envoyer Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Couleur de fond neutre
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                elevation: 2, // Légère élévation pour un effet discret
              ),
            ),
          ],
        ),
      ),
    );
  }
}
