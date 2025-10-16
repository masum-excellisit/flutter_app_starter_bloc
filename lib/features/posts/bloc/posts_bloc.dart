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
        );
}
