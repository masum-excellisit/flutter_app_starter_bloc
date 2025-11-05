import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_response.dart';
import '../api/create_post_api.dart';
import '../models/post_model.dart';

class CreatePostRepository {
  final CreatePostApi _api;

  CreatePostRepository(this._api);

  Future<PostModel> createPost(Map<String, dynamic> data) async {
    final ApiResponse<PostModel> response = await _api.createPost(data);

    if (response.data != null) {
      return response.data!;
    }

    throw ServerException(
      response.errorMessage ?? 'Failed to create post',
      statusCode: response.statusCode,
    );
  }
}
