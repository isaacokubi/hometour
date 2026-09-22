import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/tour.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.firebase);
  final FirebaseService firebase;

  bool loading = true;
  bool authenticated = false;
  Map<String, dynamic>? user;
  List<Tour> tours = [];
  List<Booking> bookings = [];
  String? error;

  String get tenantId => (user?['tenantId'] ?? '').toString();
  String get userId => firebase.currentUid ?? '';

  Future<void> bootstrap() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await firebase.restoreSession();
      authenticated = true;
      await Future.wait([loadTours(), loadBookings()]);
    } on FirebaseAuthException {
      authenticated = false;
      user = null;
    } catch (_) {
      authenticated = false;
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    error = null;
    notifyListeners();
    try {
      user = await firebase.signIn(email: email, password: password);
      authenticated = true;
      if (tenantId.isEmpty) {
        await firebase.signOut();
        user = null;
        authenticated = false;
        error = 'Your account is not linked to a Global Tours tenant.';
        notifyListeners();
        return false;
      }
      await Future.wait([loadTours(), loadBookings()]);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = _friendlyAuthError(e);
    } catch (e) {
      error = e.toString().replaceFirst('Bad state: ', '');
    }
    authenticated = false;
    notifyListeners();
    return false;
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This Firebase account has been disabled.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      default:
        return error.message ?? 'Firebase sign-in failed.';
    }
  }

  Future<void> logout() async {
    try {
      await firebase.signOut();
    } finally {
      user = null;
      authenticated = false;
      tours = [];
      bookings = [];
      error = null;
      notifyListeners();
    }
  }

  Future<void> loadTours() async {
    if (!authenticated || tenantId.isEmpty) return;
    try {
      final raw = await firebase.getTours(tenantId);
      tours = raw.map(Tour.fromJson).where((tour) => tour.id.isNotEmpty).toList();
    } catch (e) {
      error = 'Unable to load tours: $e';
    }
    notifyListeners();
  }

  Future<void> loadBookings() async {
    if (!authenticated || tenantId.isEmpty || userId.isEmpty) return;
    try {
      final raw = await firebase.getBookings(userId, tenantId);
      bookings = raw.map(Booking.fromJson).where((booking) => booking.id.isNotEmpty).toList();
    } catch (e) {
      error = 'Unable to load bookings: $e';
    }
    notifyListeners();
  }

  Future<bool> createBooking(
    String tourId,
    DateTime date,
    int travellers,
    double unitPrice,
    String tourName,
  ) async {
    try {
      await firebase.createBooking(
        uid: userId,
        tenantId: tenantId,
        tourId: tourId,
        travelDate: date,
        travellers: travellers,
        unitPrice: unitPrice,
        tourName: tourName,
      );
      await loadBookings();
      return true;
    } catch (e) {
      error = 'Booking could not be created: $e';
      notifyListeners();
      return false;
    }
  }
}
