import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _jwtKey = 'jwt_token';

  // ✅ CRITICAL FIX: Enable EncryptedSharedPrefs for Android
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _jwtKey,
      value: token,
      aOptions: _getAndroidOptions(), // ✅ Pass options
    );
    print("💾 Token Saved: ${token.substring(0, 10)}..."); // Debug print
  }

  Future<String?> getToken() async {
    final token = await _storage.read(
      key: _jwtKey,
      aOptions: _getAndroidOptions(), // ✅ Pass options
    );
    print("📂 Token Retrieved: ${token != null ? 'Yes' : 'NULL'}"); // Debug print
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(
      key: _jwtKey,
      aOptions: _getAndroidOptions(), // ✅ Pass options
    );
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const flutterSecureStorage = FlutterSecureStorage();
  return SecureStorageService(flutterSecureStorage);
});