class AuthRequestDto {
  final String email;
  final String password;

  AuthRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

