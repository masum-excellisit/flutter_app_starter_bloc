import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../models/post_request.dart';

class PostForm extends StatefulWidget {
  final PostModel? initialPost;
  final ValueChanged<PostRequest> onSubmit;

  const PostForm({
    super.key,
    this.initialPost,
    required this.onSubmit,
  });

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialPost?.title ?? '');
    _bodyController =
        TextEditingController(text: widget.initialPost?.body ?? '');
    _tagsController = TextEditingController(
      text: widget.initialPost?.tags.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList();

    final request = PostRequest(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      tags: tags,
      userId: widget.initialPost?.userId ?? 1,
    );

    widget.onSubmit(request);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialPost != null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 4,
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Body is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Comma separated tags',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Update Post' : 'Create Post'),
            ),
          ),
        ],
      ),
    );
  }
}
