// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC6Al_B-vkwtjlwhiLlVCn1-fXEPAxYQFA',
    appId: '1:1048389015994:web:f6d35a063ec19e1618a583',
    messagingSenderId: '1048389015994',
    projectId: 'darboda-flutter',
    authDomain: 'darboda-flutter.firebaseapp.com',
    storageBucket: 'darboda-flutter.appspot.com',
    measurementId: 'G-Z985PX50T0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzgo2cyjncjSLKElT7OIC0lj9hDdj1Fj4',
    appId: '1:1048389015994:android:c0349cfbcb62a97b18a583',
    messagingSenderId: '1048389015994',
    projectId: 'darboda-flutter',
    storageBucket: 'darboda-flutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJLyP_9fTECbGwI-866_i4bMo-I-PmqK4',
    appId: '1:1048389015994:ios:87f8391c236bc86d18a583',
    messagingSenderId: '1048389015994',
    projectId: 'darboda-flutter',
    storageBucket: 'darboda-flutter.appspot.com',
    androidClientId: '1048389015994-hegc0fp8hi1pqrktacrtaecaulh61tl6.apps.googleusercontent.com',
    iosClientId: '1048389015994-0ako825qqhfujiq6oeqnuq34b6i0gvv2.apps.googleusercontent.com',
    iosBundleId: 'com.example.darbodaRider',
  );
}
