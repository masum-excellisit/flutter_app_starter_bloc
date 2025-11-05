import '../../../core/bloc/paginated_crud_bloc.dart';
import '../data/posts_repository.dart';
import '../models/post_model.dart';
import '../models/post_request.dart';

class PostsBloc extends CrudBloc<PostModel, PostRequest, PostRequest, int> {
  PostsBloc(PostsRepository repository)
      : super(
          repository: repository,
          idSelector: (PostModel post) => post.id,
          updateMerger: (PostModel current, PostModel updated) =>
              current.copyWith(
            title: updated.title,
            body: updated.body,
            tags: updated.tags,
            reactions: updated.reactions,
            reactionMeta: updated.reactionMeta,
            userId: updated.userId,
          ),
          pageSize: 10,
          itemSearchFilter: _filterPost,
        );

  static bool _filterPost(
    PostModel post,
    String query,
    List<String>? fields,
  ) {
    if (fields == null || fields.isEmpty) {
      // Search all fields by default
      return post.title.toLowerCase().contains(query.toLowerCase()) ||
          post.body.toLowerCase().contains(query.toLowerCase()) ||
          post.tags
              .any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }

    final lowerQuery = query.toLowerCase();

    for (final field in fields) {
      switch (field.toLowerCase()) {
        case 'title':
          if (post.title.toLowerCase().contains(lowerQuery)) return true;
          break;
        case 'body':
          if (post.body.toLowerCase().contains(lowerQuery)) return true;
          break;
        case 'tags':
          if (post.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
            return true;
          }
          break;
      }
    }

    return false;
  }
}
