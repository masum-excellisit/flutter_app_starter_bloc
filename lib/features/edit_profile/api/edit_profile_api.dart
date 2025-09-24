import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';

import '../model/edit_profile_request.dart';
import '../model/edit_profile_response.dart';

class EditProfileApi {
  final ApiClient _client;
  EditProfileApi(this._client);

  Future<ApiResponse<EditProfileResponse>> fetchProfile() {
    return _client.getRequest<EditProfileResponse>(
      endPoint: EndPoints.getProfile,
      fromJson: (json) => EditProfileResponse.fromJson(json),
    );
  }

  Future<ApiResponse<EditProfileResponse>> updateProfile(
      EditProfileRequest request) {
    return _client.postRequest<EditProfileResponse>(
      endPoint: EndPoints.updateProfile,
      reqModel: request.toJson(),
      fromJson: (json) => EditProfileResponse.fromJson(json),
    );
  }

  Future<ApiResponse<EditProfileResponse>> updateProfileWithImage(
      EditProfileRequest request, File? imageFile) {
    return _client.uploadImage<EditProfileResponse>(
      endPoint: EndPoints.updateProfile,
      reqModel: request.toJson(),
      imageFile: imageFile,
      imageFieldName: "profile_image",
      fromJson: (json) => EditProfileResponse.fromJson(json),
    );
  }
}
