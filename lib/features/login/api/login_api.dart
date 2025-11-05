
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../model/login_response.dart';

class LoginApi {
  final ApiClient _client;
  LoginApi(this._client);

  Future<ApiResponse<LoginResponse>> login(
      String username, String password) async {
    return _client.postRequest<LoginResponse>(
      endPoint: EndPoints.userLogin,
      reqModel: {"username": username, "password": password},
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }
}
