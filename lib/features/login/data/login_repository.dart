import '../../../core/network/api_response.dart';
import '../api/login_api.dart';
import '../model/login_response.dart';

class LoginRepository {
  final LoginApi api;
  LoginRepository(this.api);

  Future<ApiResponse<LoginResponse>> login(
      String username, String password) {
    return api.login(username, password);
  }
}
