class LoginResponse {
  int? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? gender;
  String? image;
  String accessToken;
  String refreshToken;

  LoginResponse(
      {this.id,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.gender,
      this.image,
      required this.accessToken,
      required this.refreshToken});

  LoginResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'] ?? '',
        refreshToken = json['refreshToken'] ?? '' {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    gender = json['gender'];
    image = json['image'];
  }
}
