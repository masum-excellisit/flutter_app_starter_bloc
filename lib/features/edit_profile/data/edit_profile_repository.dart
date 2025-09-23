import 'dart:io';

import '../../../core/network/api_response.dart';
import '../../profile/model/profile_response.dart';
import '../api/edit_profile_api.dart';
import '../model/edit_profile_request.dart';

class EditProfileRepository {
  final EditProfileApi _api;
  EditProfileRepository(this._api);

  Future<ApiResponse<ProfileResponse>> fetchProfile() =>
      _api.fetchProfile();

  Future<ApiResponse<ProfileResponse>> updateProfile(
          EditProfileRequest request, {File? imageFile}) =>
      imageFile != null
          ? _api.updateProfileWithImage(request, imageFile)
          : _api.updateProfile(request);
}
