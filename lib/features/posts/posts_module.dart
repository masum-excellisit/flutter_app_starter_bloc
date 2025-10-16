import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/bloc/paginated_crud_bloc.dart';
import '../../core/network/api_client.dart';
import 'api/posts_api.dart';
import 'bloc/posts_bloc.dart';
import 'data/posts_local_data_source.dart';
import 'data/posts_repository.dart';
import 'models/post_request.dart';
import 'screens/posts_screen.dart';

class PostsModule {
  static Widget route() {
    final apiClient = ApiClient();
    final api = PostsApi(apiClient);
    final localDataSource = PostsLocalDataSource();
    final repository = PostsRepository(api, localDataSource);

    return BlocProvider<PostsBloc>(
      create: (_) => PostsBloc(repository)
        ..add(
            const LoadItemsEvent<PostRequest, PostRequest, int>(refresh: true)),
      child: const PostsScreen(),
    );
  }
}
