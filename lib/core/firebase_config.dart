import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static String _get(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty || value.startsWith('REPLACE_WITH_')) {
      throw StateError(
        'Missing Firebase configuration: $key. '
        'Copy .env.example to .env and enter the Firebase client configuration.',
      );
    }
    return value;
  }

  static FirebaseOptions get currentPlatform {
    final apiKey = _get('FIREBASE_API_KEY');
    final projectId = _get('FIREBASE_PROJECT_ID');
    final senderId = _get('FIREBASE_MESSAGING_SENDER_ID');

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: _get('FIREBASE_APP_ID'),
        messagingSenderId: senderId,
        projectId: projectId,
        authDomain: dotenv.maybeGet('FIREBASE_AUTH_DOMAIN'),
        storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        measurementId: dotenv.maybeGet('FIREBASE_MEASUREMENT_ID'),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: _get('FIREBASE_ANDROID_APP_ID'),
          messagingSenderId: senderId,
          projectId: projectId,
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: _get('FIREBASE_IOS_APP_ID'),
          messagingSenderId: senderId,
          projectId: projectId,
          storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET'),
          iosBundleId: dotenv.maybeGet('FIREBASE_IOS_BUNDLE_ID'),
        );
      default:
        throw UnsupportedError(
          'Global Tours Firebase configuration does not support $defaultTargetPlatform.',
        );
    }
  }
}
