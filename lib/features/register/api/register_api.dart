
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../model/register_request.dart';

class RegisterApi {
  final ApiClient _client;

  RegisterApi(this._client);

  Future<ApiResponse<Map<String, dynamic>>> register(
      RegisterRequest request) async {
    return _client.postRequest<Map<String, dynamic>>(
      endPoint: EndPoints.register, // make sure you have this in api_urls.dart
      reqModel: request.toJson(),
      fromJson: (json) => json, // raw map return
    );
  }
}
