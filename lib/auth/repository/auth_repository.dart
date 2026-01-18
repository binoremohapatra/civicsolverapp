import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  // ================= REGISTER (FIXED) =================
  // ✅ UPDATE 1: Added 'name' to the method arguments
  Future<String> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'name': name,       // ✅ UPDATE 2: Sending name to backend
          'email': email,
          'password': password,
          'role': 'USER',     // ✅ UPDATE 3: Sending default role
        },
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final token = data['token'];

      if (token == null || token is! String) {
        throw Exception('Token not returned from backend');
      }

      await _storage.saveToken(token);
      return token;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
              e.message ??
              'Registration failed';
      throw Exception(message);
    }
  }

  // ================= LOGIN =================
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response from server');
      }

      final data = response.data as Map<String, dynamic>;
      final token = data['token'];

      if (token == null || token is! String) {
        throw Exception('Token not returned from backend');
      }

      await _storage.saveToken(token);
      return token;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
              e.message ??
              'Login failed';
      throw Exception(message);
    }
  }

  // ================= TOKEN =================
  Future<String?> getToken() async {
    return _storage.getToken();
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _storage.deleteToken();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(dioClient.dio, storage);
});