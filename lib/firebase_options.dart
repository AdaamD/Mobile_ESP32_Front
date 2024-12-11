// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDA3g2uX1wz5LdE9RKAkSPjrsARrwB5hFw',
    appId: '1:444126053400:web:6cf8dc64f5c6bd1b06af6d',
    messagingSenderId: '444126053400',
    projectId: 'esp32-flutter-app-7b535',
    authDomain: 'esp32-flutter-app-7b535.firebaseapp.com',
    storageBucket: 'esp32-flutter-app-7b535.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHQOZi4BcmWjsFe9aw2f2n-1dl5Unp4SI',
    appId: '1:444126053400:android:607d14e94339863706af6d',
    messagingSenderId: '444126053400',
    projectId: 'esp32-flutter-app-7b535',
    storageBucket: 'esp32-flutter-app-7b535.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBAFkJljg-QMcyC6K_gn2ZqbDxQp6qM4c',
    appId: '1:444126053400:ios:2a05fd35ab3cfca206af6d',
    messagingSenderId: '444126053400',
    projectId: 'esp32-flutter-app-7b535',
    storageBucket: 'esp32-flutter-app-7b535.firebasestorage.app',
    iosBundleId: 'com.example.flutterEsp32Application',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBAFkJljg-QMcyC6K_gn2ZqbDxQp6qM4c',
    appId: '1:444126053400:ios:2a05fd35ab3cfca206af6d',
    messagingSenderId: '444126053400',
    projectId: 'esp32-flutter-app-7b535',
    storageBucket: 'esp32-flutter-app-7b535.firebasestorage.app',
    iosBundleId: 'com.example.flutterEsp32Application',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDA3g2uX1wz5LdE9RKAkSPjrsARrwB5hFw',
    appId: '1:444126053400:web:3c3de125a40439f306af6d',
    messagingSenderId: '444126053400',
    projectId: 'esp32-flutter-app-7b535',
    authDomain: 'esp32-flutter-app-7b535.firebaseapp.com',
    storageBucket: 'esp32-flutter-app-7b535.firebasestorage.app',
  );
}