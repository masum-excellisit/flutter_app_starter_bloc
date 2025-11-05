class EditProfileRequest {
  String? firstName;
  String? email;

  EditProfileRequest({
    this.firstName,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['email'] = email;
    return data;
  }
}
