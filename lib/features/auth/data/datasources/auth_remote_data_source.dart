import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Login failed');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post('/users/add', data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      });

      // For dummy API, we might need to handle registration differently
      // as it might not return a token directly
      return AuthResponseModel(
        token: 'dummy_token', // In real scenario, this would come from response
        user: response.data,
      );
    } catch (e) {
      throw ServerException('Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // In a real scenario, you might call a logout endpoint
      // await apiClient.post('/auth/logout');

      // For now, we'll just simulate the logout
    } catch (e) {
      throw ServerException('Logout failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw ServerException('Failed to get current user');
    }
  }
}
