import '../../../core/domain/crud_repository.dart';
import '../../../core/models/paginated_result.dart';
import '../../../core/network/api_response.dart';
import '../api/posts_api.dart';
import '../models/post_model.dart';
import '../models/post_request.dart';
import 'posts_local_data_source.dart';

class PostsRepository
    implements CrudRepository<PostModel, PostRequest, PostRequest, int> {
  final PostsApi _api;
  final PostsLocalDataSource _localDataSource;

  PostsRepository(this._api, this._localDataSource);

  @override
  Future<PaginatedResult<PostModel>> fetchPage({
    required int page,
    required int pageSize,
    String? search,
  }) async {
    final ApiResponse<PaginatedResult<PostModel>> response =
        await _api.fetchPosts(page: page, pageSize: pageSize, search: search);

    if (response.data != null) {
      return response.data!;
    }

    throw Exception(response.errorMessage ?? 'Failed to load posts');
  }

  @override
  Future<PostModel> create(PostRequest payload) async {
    final ApiResponse<PostModel> response = await _api.createPost(payload);

    if (response.data != null) {
      return response.data!;
    }

    throw Exception(response.errorMessage ?? 'Failed to create post');
  }

  @override
  Future<PostModel> update(int id, PostRequest payload) async {
    final ApiResponse<PostModel> response = await _api.updatePost(id, payload);

    if (response.data != null) {
      return response.data!;
    }

    throw Exception(response.errorMessage ?? 'Failed to update post');
  }

  @override
  Future<void> delete(int id) async {
    final ApiResponse<Map<String, dynamic>> response =
        await _api.deletePost(id);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(response.errorMessage ?? 'Failed to delete post');
  }

  @override
  Future<void> cacheItems(List<PostModel> items) async {
    await _localDataSource.cachePosts(items);
  }

  @override
  Future<List<PostModel>> getCachedItems() {
    return _localDataSource.getCachedPosts();
  }
}
