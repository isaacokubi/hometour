import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration is loaded from the non-secret .env asset.
/// Do not put service-account credentials or private server keys in this app.
class DefaultFirebaseOptions {
  static String _required(String key) {
    const values = <String, String>{};
    throw StateError(
      'Firebase configuration is not embedded. Load .env before calling '
      'DefaultFirebaseOptions. Missing key: $key. '
      'Run flutterfire configure or provide the Firebase client values in .env.',
    );
  }

  static FirebaseOptions get currentPlatform {
    throw StateError(
      'Firebase configuration is not initialized. '
      'Run flutterfire configure and replace lib/firebase_options.dart with '
      'the generated file, or configure the environment-backed options in '
      'this file before running the app.',
    );
  }
}
