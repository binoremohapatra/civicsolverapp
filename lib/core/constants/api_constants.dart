class ApiConstants {
  // ✅ REAL backend URL (Hugging Face)
  static const String baseUrl = 'https://mrbaddy-civicsolver-backend.hf.space';

  // ================= AUTH =================
  static const String registerEndpoint = '/api/v1/auth/user-register';
  static const String loginEndpoint = '/api/v1/auth/user-login';

  // ================= COMPLAINTS =================
  static const String complaintsEndpoint = '/api/v1/complaints';

  static String complaintDetailEndpoint(String id) =>
      '/api/v1/complaints/$id';

  static String requestOtpEndpoint(String id) =>
      '/api/v1/complaints/$id/request-otp';

  static String closeComplaintEndpoint(String id) =>
      '/api/v1/complaints/$id/close';

  static String appealComplaintEndpoint(String id) =>
      '/api/v1/complaints/$id/appeal';

  // Helper for Image URLs
  static String getImageUrl(String imagePath) =>
      '$baseUrl/uploads/$imagePath';
}