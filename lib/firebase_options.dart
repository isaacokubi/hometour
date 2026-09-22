import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      FirebaseConfig.currentPlatform;
}
