import '../../../core/models/paginated_result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../models/post_model.dart';
import '../models/post_request.dart';

class PostsApi {
  final ApiClient _client;

  PostsApi(this._client);

  Future<ApiResponse<PaginatedResult<PostModel>>> fetchPosts({
    required int page,
    required int pageSize,
    String? search,
  }) {
    final bool hasQuery = search != null && search.isNotEmpty;
    final String endpoint = hasQuery ? EndPoints.postsSearch : EndPoints.posts;
    final int skip = page * pageSize;

    final queryParameters = <String, dynamic>{
      'limit': pageSize,
      'skip': skip,
      if (hasQuery) 'q': search,
    };

    return _client.getRequest<PaginatedResult<PostModel>>(
      endPoint: endpoint,
      queryParameters: queryParameters,
      fromJson: (Map<String, dynamic> json) {
        final List<dynamic> postsJson =
            json['posts'] as List<dynamic>? ?? const [];
        final int total = (json['total'] as num?)?.toInt() ?? postsJson.length;
        final int limit = (json['limit'] as num?)?.toInt() ?? pageSize;
        final int currentSkip = (json['skip'] as num?)?.toInt() ?? skip;
        final int currentPage = limit == 0 ? 0 : currentSkip ~/ limit;

        final List<PostModel> posts = postsJson
            .map((dynamic e) => PostModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();

        return PaginatedResult<PostModel>(
          items: posts,
          total: total,
          page: currentPage,
          pageSize: limit,
        );
      },
    );
  }

  Future<ApiResponse<PostModel>> createPost(PostRequest request) {
    return _client.postRequest<PostModel>(
      endPoint: EndPoints.postsAdd,
      reqModel: request.toJson(),
      fromJson: (Map<String, dynamic> json) => PostModel.fromJson(json),
    );
  }

  Future<ApiResponse<PostModel>> updatePost(int id, PostRequest request) {
    return _client.putRequest<PostModel>(
      endPoint: '${EndPoints.posts}/$id',
      reqModel: request.toJson(),
      fromJson: (Map<String, dynamic> json) => PostModel.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePost(int id) {
    return _client.deleteRequest(
      endPoint: '${EndPoints.posts}/$id',
    );
  }
}
