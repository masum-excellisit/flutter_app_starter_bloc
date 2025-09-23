import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../../profile/model/profile_response.dart';
import '../model/edit_profile_request.dart';

class EditProfileApi {
  final ApiClient _client;
  EditProfileApi(this._client);

  Future<ApiResponse<ProfileResponse>> fetchProfile() {
    return _client.getRequest<ProfileResponse>(
      endPoint: EndPoints.getProfile,
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }

  Future<ApiResponse<ProfileResponse>> updateProfile(
      EditProfileRequest request) {
    return _client.postRequest<ProfileResponse>(
      endPoint: EndPoints.updateProfile,
      reqModel: request.toJson(),
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }

  Future<ApiResponse<ProfileResponse>> updateProfileWithImage(
      EditProfileRequest request, File? imageFile) {
    return _client.uploadImage<ProfileResponse>(
      endPoint: EndPoints.updateProfile,
      reqModel: request.toJson(),
      imageFile: imageFile,
      imageFieldName: "profile_image",
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }
}
