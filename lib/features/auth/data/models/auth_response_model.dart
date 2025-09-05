class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic> user;

  AuthResponseModel({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
      user: json['user'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user,
    };
  }
}
