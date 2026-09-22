import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  String? get currentUid => auth.currentUser?.uid;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase authentication returned no user.');
    }
    return _loadUserProfile(user);
  }

  Future<Map<String, dynamic>> _loadUserProfile(User user) async {
    final snapshot = await firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      await auth.signOut();
      throw StateError(
        'Your Firebase account is authenticated, but no Global Tours user profile exists.',
      );
    }

    final data = Map<String, dynamic>.from(snapshot.data()!);
    data['id'] = user.uid;
    data['email'] = data['email'] ?? user.email ?? '';
    data['name'] = data['name'] ?? user.displayName ?? '';
    if ((data['tenantId'] ?? '').toString().isEmpty) {
      final configuredTenant = dotenv.maybeGet('DEFAULT_TENANT_ID')?.trim();
      if (configuredTenant != null && configuredTenant.isNotEmpty) {
        data['tenantId'] = configuredTenant;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> restoreSession() async {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('No Firebase session is active.');
    }
    return _loadUserProfile(user);
  }

  Stream<User?> authStateChanges() => auth.authStateChanges();

  Future<void> signOut() => auth.signOut();

  Future<List<Map<String, dynamic>>> getTours(String tenantId) async {
    if (tenantId.isEmpty) {
      throw StateError('A tenant is required to load tours.');
    }

    final snapshot = await firestore
        .collection('tours')
        .where('tenantId', isEqualTo: tenantId)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getBookings(String uid, String tenantId) async {
    if (uid.isEmpty || tenantId.isEmpty) {
      return [];
    }

    final snapshot = await firestore
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('tenantId', isEqualTo: tenantId)
        .limit(100)
        .get();

    final results = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    results.sort((a, b) {
      final aDate = _timestampValue(a['createdAt']);
      final bDate = _timestampValue(b['createdAt']);
      return bDate.compareTo(aDate);
    });
    return results;
  }

  Future<void> createBooking({
    required String uid,
    required String tenantId,
    required String tourId,
    required DateTime travelDate,
    required int travellers,
    required double unitPrice,
    required String tourName,
  }) async {
    if (uid.isEmpty || tenantId.isEmpty || tourId.isEmpty) {
      throw StateError('User, tenant and tour are required to create a booking.');
    }
    if (travellers < 1) {
      throw ArgumentError.value(travellers, 'travellers', 'Must be at least 1.');
    }

    await firestore.collection('bookings').add({
      'userId': uid,
      'tenantId': tenantId,
      'tourId': tourId,
      'tourName': tourName,
      'travelDate': Timestamp.fromDate(travelDate),
      'numberOfGuests': travellers,
      'unitPrice': unitPrice,
      'totalAmount': unitPrice * travellers,
      'status': 'pending',
      'bookingSource': 'mobile_app',
      'paymentMethod': 'MPESA',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  double _timestampValue(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch.toDouble();
    if (value is DateTime) return value.millisecondsSinceEpoch.toDouble();
    return DateTime.tryParse(value?.toString() ?? '')?.millisecondsSinceEpoch.toDouble() ?? 0;
  }
}
