import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;

  DioClient(this._dio, this._secureStorageService) {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20), // Increased timeout for uploads
      receiveTimeout: const Duration(seconds: 20),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          // ✅ FIX: Handle 403 (Ghost Token) same as 401
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await _secureStorageService.deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorageService = ref.read(secureStorageProvider);
  return DioClient(Dio(), secureStorageService);
});