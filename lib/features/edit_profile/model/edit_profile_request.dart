class EditProfileRequest {
  final String name;
  final String email;

  EditProfileRequest({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
      };
}
