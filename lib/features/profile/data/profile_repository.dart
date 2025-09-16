import '../../../core/network/api_response.dart';
import '../api/profile_api.dart';
import '../model/profile_response.dart';


class ProfileRepository {
  final ProfileApi _api;
  ProfileRepository(this._api);

  Future<ApiResponse<ProfileResponse>> fetchProfile() {
    return _api.fetchProfile();
  }
}
