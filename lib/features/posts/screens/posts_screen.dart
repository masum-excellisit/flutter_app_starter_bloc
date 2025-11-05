import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/paginated_crud_bloc.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/paginated_list_view.dart';
import '../../../core/widgets/search_input.dart';
import '../bloc/posts_bloc.dart';
import '../models/post_model.dart';
import '../models/post_request.dart';
import '../widgets/post_card.dart';
import '../widgets/post_form.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  PostsBloc get _bloc => context.read<PostsBloc>();

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _bloc.add(SearchItemsEvent<PostRequest, PostRequest, int>(value));
    });
  }

  Future<void> _onRefresh() async {
    _bloc.add(
        const LoadItemsEvent<PostRequest, PostRequest, int>(refresh: true));
  }

  void _openCreatePost() {
    _openPostForm();
  }

  void _openEditPost(PostModel post) {
    _openPostForm(initialPost: post, postId: post.id);
  }

  void _openPostForm({PostModel? initialPost, int? postId}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: PostForm(
              initialPost: initialPost,
              onSubmit: (PostRequest request) {
                Navigator.of(context).pop();
                if (postId == null) {
                  _bloc.add(
                      CreateItemEvent<PostRequest, PostRequest, int>(request));
                } else {
                  _bloc.add(UpdateItemEvent<PostRequest, PostRequest, int>(
                      postId, request));
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(PostModel post) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: Text('Are you sure you want to delete "${post.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _bloc.add(
                    DeleteItemEvent<PostRequest, PostRequest, int>(post.id));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsBloc, CrudState<PostModel>>(
      listenWhen:
          (CrudState<PostModel> previous, CrudState<PostModel> current) =>
              previous.feedbackMessage != current.feedbackMessage,
      listener: (BuildContext context, CrudState<PostModel> state) {
        final String? message = state.feedbackMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: state.feedbackIsError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          );
          _bloc.add(const ClearFeedbackEvent<PostRequest, PostRequest, int>());
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: const Text('Posts')),
        floatingActionButton: FloatingActionButton(
          onPressed: _openCreatePost,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ReusableSearchInput(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search posts',
              ),
            ),
            BlocBuilder<PostsBloc, CrudState<PostModel>>(
              builder: (BuildContext context, CrudState<PostModel> state) {
                return Expanded(
                  child: Column(
                    children: [
                      if (state.isOffline)
                        Container(
                          width: double.infinity,
                          color: Colors.amber.shade100,
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            'You are viewing offline data.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(child: _buildContent(state)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CrudState<PostModel> state) {
    if (state.status == CrudStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CrudStatus.failure && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? 'Unable to load posts.',
        onRetry: () => _bloc.add(
            const LoadItemsEvent<PostRequest, PostRequest, int>(refresh: true)),
      );
    }

    return PaginatedListView<PostModel>(
      items: state.items,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      onLoadMore: state.hasMore
          ? () => _bloc
              .add(const LoadMoreItemsEvent<PostRequest, PostRequest, int>())
          : null,
      onRefresh: _onRefresh,
      emptyState: _EmptyState(onCreate: _openCreatePost),
      itemBuilder: (BuildContext context, PostModel post, int index) {
        return PostCard(
          post: post,
          onEdit: () => _openEditPost(post),
          onDelete: () => _confirmDelete(post),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No posts yet. Create your first post to get started.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
