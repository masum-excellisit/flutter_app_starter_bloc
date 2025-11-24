import 'package:flutter/material.dart';

import '../models/recipes_model.dart';
import '../models/recipes_request.dart';

class RecipeForm extends StatefulWidget {
  final RecipeModel? initialModel;
  final ValueChanged<RecipeRequest> onSubmit;

  const RecipeForm({Key? key, this.initialModel, required this.onSubmit})
      : super(key: key);

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialModel?.name ?? '');
    _bodyCtrl = TextEditingController(text: widget.initialModel?.cuisine ?? '');
    _tagsCtrl = TextEditingController(
        text: widget.initialModel?.tags!.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final tags = _tagsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final req = RecipeRequest(
      name: _titleCtrl.text.trim(),
      cuisine: _bodyCtrl.text.trim(),
      tags: tags,
      userId: widget.initialModel?.userId ?? 1,
    );
    widget.onSubmit(req);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 4,
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Body is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(
                labelText: 'Tags', hintText: 'Comma separated'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
