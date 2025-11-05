import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

class CreatePostForm extends StatefulWidget {
  const CreatePostForm({super.key});

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final data = {
      'title': _titleController.text.trim(),
      'body': _bodyController.text.trim(),
      'tags': tags,
      'userId': 1,
    };

    context.read<CreatePostBloc>().add(SubmitPostEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePostBloc, CreatePostState>(
      builder: (context, state) {
        final isLoading = state.status == CreatePostStatus.loading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
                validator: (value) => Validators.required(value, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                enabled: !isLoading,
                validator: (value) => Validators.required(value, 'Body'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g., flutter, dart, mobile',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Post'),
              ),
            ],
          ),
        );
      },
    );
  }
}
