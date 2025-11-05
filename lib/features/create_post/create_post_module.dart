import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import 'api/create_post_api.dart';
import 'bloc/create_post_bloc.dart';
import 'data/create_post_repository.dart';
import 'screens/create_post_screen.dart';

class CreatePostModule {
  static Widget route() {
    final api = CreatePostApi(ApiClient());
    final repository = CreatePostRepository(api);

    return BlocProvider(
      create: (_) => CreatePostBloc(repository),
      child: const CreatePostScreen(),
    );
  }
}
