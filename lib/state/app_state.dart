import 'package:dio/dio.dart';
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
    } on DioException catch (e) {
      error = _friendlyDioError(e);
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  String _friendlyDioError(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to the Global Tours server. Make sure the server is running on port 5000 and the API URL is correct.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The Global Tours server took too long to respond. Check that the server is running.';
    }

    final status = response?.statusCode;
    if (status != null) {
      return 'Login failed (HTTP $status). Check your email, password, and tenant/company settings.';
    }

    return 'Login failed. Check that the Global Tours API is running and reachable.';
  }

  Future<void> logout() async { try { await api.post('/auth/logout'); } catch (_) {} await api.clearSession(); user=null; authenticated=false; notifyListeners(); }

  Future<void> loadTours() async {
    try {
      final raw = await api.get('/tours', query: {'limit': 50});
      final dynamic list = raw is Map ? (raw['data'] ?? raw['tours'] ?? []) : raw;
      if (list is List) {
        tours = list
            .whereType<Map>()
            .map((e) => Tour.fromJson(Map<String, dynamic>.from(e)))
            .where((tour) => tour.id.isNotEmpty)
            .toList();
      }
    } catch (e) { error = e.toString(); }
    notifyListeners();
  }

  Future<void> loadBookings() async {
    if (!authenticated) return;
    try {
      final raw = await api.get('/bookings/my-bookings', query: {'limit': 100});
      final dynamic container = raw is Map ? (raw['data'] ?? raw) : raw;
      final dynamic list = container is Map
          ? (container['bookings'] ?? container['data'] ?? [])
          : container;
      if (list is List) {
        bookings = list
            .whereType<Map>()
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> createBooking(String tourId, DateTime date, int travellers) async {
    try {
      await api.post('/bookings', data: {'tour': tourId, 'travelDate': date.toIso8601String(), 'numberOfGuests': travellers,
        'bookingSource': 'mobile_app',
        'paymentMethod': 'MPESA'});
      await loadBookings(); return true;
    } on DioException catch (e) {
      final response = e.response?.data;
      error = response is Map && response['message'] != null ? response['message'].toString() : 'Booking could not be created.';
      notifyListeners();
      return false;
    } catch (_) { error='Booking could not be created.'; notifyListeners(); return false; }
  }
}
