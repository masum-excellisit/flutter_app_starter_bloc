class ProfileResponse {
  final String id;
  final String name;
  final String email;
  final String avatar;

  ProfileResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
