import 'package:flutter/material.dart';
// flutter_bloc and paginated_crud_bloc not required when using CrudModule
import '../../core/network/api_urls.dart';
import '../../core/modules/crud_module.dart';
import 'models/post_model.dart';
import 'models/post_request.dart';
import 'screens/posts_screen.dart';

class PostsModule {
  static Widget route() {
    // Use CrudModule to build a configured Bloc that uses generic API + cache
    return CrudModule.route<PostModel, PostRequest, PostRequest, int>(
      child: const PostsScreen(),
      fromJson: PostModel.fromJson,
      toJson: (PostModel p) => p.toJson(),
      idSelectorFn: (PostModel p) => p.id,
      baseEndpoint: EndPoints.posts,
      createEndpoint: EndPoints.postsAdd,
      updateEndpointPrefix: EndPoints.posts,
      itemsKey: 'posts',
      createMapper: (PostRequest r) => r.toJson(),
      updateMapper: (PostRequest r) => r.toJson(),
      updateMerger: (PostModel current, PostModel updated) => current.copyWith(
        title: updated.title,
        body: updated.body,
        tags: updated.tags,
        reactions: updated.reactions,
        reactionMeta: updated.reactionMeta,
        userId: updated.userId,
      ),
      itemSearchFilter: (PostModel post, String query, List<String>? fields) {
        if (fields == null || fields.isEmpty) {
          return post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.body.toLowerCase().contains(query.toLowerCase()) ||
              post.tags.any(
                  (tag) => tag.toLowerCase().contains(query.toLowerCase()));
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
              if (post.tags
                  .any((tag) => tag.toLowerCase().contains(lowerQuery))) {
                return true;
              }
              break;
          }
        }

        return false;
      },
      pageSize: 10,
    );

    // The CrudModule call above returns the configured provider.
  }
}
