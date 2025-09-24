import 'dart:io';

import '../../../core/network/api_response.dart';

import '../api/edit_profile_api.dart';
import '../model/edit_profile_request.dart';
import '../model/edit_profile_response.dart';


class EditProfileRepository {
  final EditProfileApi _api;
  EditProfileRepository(this._api);

  Future<ApiResponse<EditProfileResponse>> fetchProfile() =>
      _api.fetchProfile();

  Future<ApiResponse<EditProfileResponse>> updateProfile(
          EditProfileRequest request, {File? imageFile}) =>
      imageFile != null
          ? _api.updateProfileWithImage(request, imageFile)
          : _api.updateProfile(request);
}
