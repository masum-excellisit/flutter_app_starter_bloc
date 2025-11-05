import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../models/post_model.dart';

class CreatePostApi {
  final ApiClient _client;

  CreatePostApi(this._client);

  Future<ApiResponse<PostModel>> createPost(Map<String, dynamic> data) {
    return _client.postRequest<PostModel>(
      endPoint: EndPoints.postsAdd,
      reqModel: data,
      fromJson: (json) => PostModel.fromJson(json),
    );
  }
}
