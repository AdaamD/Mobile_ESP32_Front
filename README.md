# Implémentation d’une Interface Flutter pour l’API RESTful du Projet Capteur TTGO T-Display

Ce projet Flutter intègre un ESP32 pour interagir avec des capteurs environnementaux via une API RESTful. L'application récupère des données en temps réel (température, luminosité) et contrôle des dispositifs matériels (LEDs) via un microcontrôleur ESP32. Les données sont stockées dans Firebase Firestore pour une gestion à long terme.

## Fonctionnalités

- Affichage des données en temps réel
- Contrôle de la LED à distance
- Envoi de message à l’ESP32
- Visualisation des statistiques de mesures
- Mise à jour du seuil de lumière
- Page d’affichage des dernières mesures relevées

## Pour commencer

### Prérequis

- SDK Flutter : [Installer Flutter](https://flutter.dev/docs/get-started/install)
- Carte ESP32 avec capacités Bluetooth
- Android Studio ou Visual Studio Code

### Installation

1. Cloner le dépôt :
    ```sh
    git clone https://github.com/AdaamD/Mobile_ESP32_Front
    cd mobile_esp32_front
    ```

2. Installer les dépendances :
    ```sh
    flutter pub get
    ```

3. Connectez votre appareil ou démarrez un émulateur.

4. Exécuter l'application :
    ```sh
    flutter run
    ```

## Utilisation

1. Assurez-vous que votre appareil ESP32 est allumé et que les branchements sont bien effectués.
2. Ouvrez l'application et accédez à l'interface graphique.
4. Utilisez l'application pour contrôler et surveiller votre appareil ESP32.

## Auteurs 
* Adam DAIA
* Mohammed DAFAOUI

## Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation ESP32](https://docs.espressif.com/projects/esp-idf/en/latest/)


