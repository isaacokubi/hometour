import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient({String? baseUrl, this.tenantSlug})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ??
                const String.fromEnvironment(
                  'API_URL',
                  defaultValue: 'http://10.0.2.2:5000/api',
                ),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio dio;
  final String? tenantSlug;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> configure() async {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'token');
          final tenantId = await storage.read(key: 'tenantId');
          final savedSlug = await storage.read(key: 'tenantSlug');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (tenantId != null && tenantId.isNotEmpty) {
            options.headers['X-Tenant-ID'] = tenantId;
          } else {
            final slug = tenantSlug ?? savedSlug;
            if (slug != null && slug.isNotEmpty) {
              options.headers['X-Tenant-Slug'] = slug;
            }
          }

          handler.next(options);
        },
      ),
    );
  }

  Future<void> saveSession(Map<String, dynamic> user, {String? token}) async {
    if (token != null && token.isNotEmpty) {
      await storage.write(key: 'token', value: token);
    }

    final id =
        user['tenantId'] is Map ? user['tenantId']['_id'] : user['tenantId'];

    if (id != null) {
      await storage.write(key: 'tenantId', value: id.toString());
    }

    if (user['tenantSlug'] != null) {
      await storage.write(
        key: 'tenantSlug',
        value: user['tenantSlug'].toString(),
      );
    }
  }

  Future<void> clearSession() => storage.deleteAll();

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
  }) async =>
      (await dio.get(path, queryParameters: query)).data;

  Future<dynamic> post(
    String path, {
    dynamic data,
  }) async =>
      (await dio.post(path, data: data)).data;
}
