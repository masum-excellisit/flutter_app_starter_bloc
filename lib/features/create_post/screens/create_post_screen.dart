import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';
import '../widgets/create_post_form.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePostBloc, CreatePostState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreatePostStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(state.post);
        } else if (state.status == CreatePostStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to create post'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: const Text('Create Post')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: CreatePostForm(),
        ),
      ),
    );
  }
}
