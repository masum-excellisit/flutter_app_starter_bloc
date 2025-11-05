
import '../../../core/network/api_response.dart';
import '../api/register_api.dart';
import '../model/register_request.dart';

class RegisterRepository {
  final RegisterApi _api;

  RegisterRepository(this._api);

  Future<ApiResponse<Map<String, dynamic>>> register(
      RegisterRequest request) {
    return _api.register(request);
  }
}
