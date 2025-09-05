import '../../../../core/network/api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getProfile() async {
    return {'id': 1, 'name': 'Test User', 'email': 'test@example.com'};
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profile) async {
    return profile;
  }
}
