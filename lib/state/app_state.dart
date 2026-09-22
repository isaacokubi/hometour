import 'package:flutter/foundation.dart';
import '../core/api.dart';
import '../models/tour.dart';
import '../models/booking.dart';

class AppState extends ChangeNotifier {
  AppState(this.api);
  final ApiClient api;
  bool loading = true, authenticated = false;
  Map<String, dynamic>? user;
  List<Tour> tours = [];
  List<Booking> bookings = [];
  String? error;

  Future<void> bootstrap() async {
    loading = true; notifyListeners(); await api.configure();
    try {
      final data = await api.get('/auth/me');
      user = Map<String, dynamic>.from(data['user'] is Map ? data['user'] : data);
      authenticated = true; await loadTours(); await loadBookings();
    } catch (_) { authenticated = false; }
    loading = false; notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    error = null; notifyListeners();
    try {
      final data = Map<String, dynamic>.from(await api.post('/auth/login', data: {'email': email.trim().toLowerCase(), 'password': password}));
      if (data['mfaRequired'] == true) { error = 'MFA is required for this account.'; notifyListeners(); return false; }
      final u = Map<String, dynamic>.from(data['user'] is Map ? data['user'] : {});
      await api.saveSession(u, token: data['token']?.toString() ?? data['accessToken']?.toString());
      user = u; authenticated = true; await loadTours(); await loadBookings(); notifyListeners(); return true;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<void> logout() async { try { await api.post('/auth/logout'); } catch (_) {} await api.clearSession(); user=null; authenticated=false; notifyListeners(); }

  Future<void> loadTours() async {
    try {
      final raw = await api.get('/tours', query: {'limit': 50});
      final list = raw is List ? raw : (raw['data'] ?? raw['tours'] ?? []);
      tours = (list as List).whereType<Map>().map((e) => Tour.fromJson(Map<String,dynamic>.from(e))).toList();
    } catch (e) { error = e.toString(); }
    notifyListeners();
  }

  Future<void> loadBookings() async {
    if (!authenticated) return;
    try {
      final raw = await api.get('/bookings/my-bookings', query: {'limit': 100});
      final list = raw is List ? raw : (raw['data'] ?? raw['bookings'] ?? []);
      bookings = (list as List).whereType<Map>().map((e) => Booking.fromJson(Map<String,dynamic>.from(e))).toList();
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> createBooking(String tourId, DateTime date, int travellers) async {
    try {
      await api.post('/bookings', data: {'tour': tourId, 'travelDate': date.toIso8601String(), 'numberOfTravelers': travellers});
      await loadBookings(); return true;
    } catch (e) { error=e.toString(); notifyListeners(); return false; }
  }
}
