import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../models/complaint_model.dart';

class ComplaintRepository {
  final DioClient _dioClient;
  final SecureStorageService _storage;

  ComplaintRepository(this._dioClient, this._storage);

  // ================= GET ALL =================
  Future<List<ComplaintModel>> getComplaints() async {
    final response = await _dioClient.dio.get(ApiConstants.complaintsEndpoint);
    return (response.data as List)
        .map((e) => ComplaintModel.fromJson(e))
        .toList();
  }

  // ================= GET BY ID =================
  Future<ComplaintModel> getComplaintById(String id) async {
    final response = await _dioClient.dio.get(
      ApiConstants.complaintDetailEndpoint(id),
    );
    return ComplaintModel.fromJson(response.data);
  }

  // ================= CREATE COMPLAINT (FIXED) =================
  Future<void> createComplaint({
    required String title,
    required String description,
    required String category, // ✅ Added
    required String location, // ✅ Added
    File? imageFile,
  }) async {
    // 1. Get Token Manually
    final token = await _storage.getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    // 2. Prepare Data (Include new fields)
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'category': category,   // ✅ Pass to backend
      'location': location,   // ✅ Pass to backend
      if (imageFile != null)
        'evidencePhoto': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    // 3. Use fresh Dio to avoid header conflicts with Multipart
    final cleanDio = Dio();

    // 4. Send Request
    final response = await cleanDio.post(
      '${ApiConstants.baseUrl}${ApiConstants.complaintsEndpoint}',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed (${response.statusCode}): ${response.data}');
    }
  }

  // ================= OTHER METHODS =================
  Future<void> requestOtp(String id) async {
    await _dioClient.dio.post(ApiConstants.requestOtpEndpoint(id));
  }

  Future<void> closeComplaint(String id, String otp) async {
    await _dioClient.dio.post(
      ApiConstants.closeComplaintEndpoint(id),
      data: {'otp': otp},
    );
  }

  Future<void> appealComplaint(String id) async {
    await _dioClient.dio.post(
      ApiConstants.appealComplaintEndpoint(id),
      data: {
        "reason": "Citizen requested appeal via mobile app",
        "action": "APPEAL"
      },
    );
  }

  Future<Map<String, int>> getComplaintStats() async {
    // You can implement a real endpoint for this if your backend supports it
    return {'open': 0, 'resolved': 0, 'urgent': 0};
  }
}

// ✅ PROVIDER
final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final storage = ref.read(secureStorageProvider);
  return ComplaintRepository(dioClient, storage);
});