import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../model/profile_response.dart';

class ProfileApi {
  final ApiClient _client;
  ProfileApi(this._client);

  Future<ApiResponse<ProfileResponse>> fetchProfile() {
    return _client.getRequest<ProfileResponse>(
      endPoint: EndPoints.profile,
      fromJson: (json) => ProfileResponse.fromJson(json),
    );
  }
}

