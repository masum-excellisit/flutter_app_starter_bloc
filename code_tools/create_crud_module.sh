#!/usr/bin/env bash

# Interactive CRUD module generator
# Creates a reusable CRUD module using the project's generic CRUD utilities
# Usage: sh create_crud_module.sh [module_name]

set -e

MODULE_NAME=$1
if [ -z "$MODULE_NAME" ]; then
  read -p "Enter new module name (plural, e.g. posts, products): " MODULE_NAME
fi

# Lowercase the name and trim
MODULE_NAME_LOWER="$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')"

# Create both plural & singular capitalized variants
PLURAL_CAPITALIZED="$(tr '[:lower:]' '[:upper:]' <<< ${MODULE_NAME_LOWER:0:1})${MODULE_NAME_LOWER:1}"

# Simple singularizer: 'ies' -> 'y', trailing 's' -> remove it
SINGULAR_BASE="$MODULE_NAME_LOWER"
if [[ "$SINGULAR_BASE" =~ ies$ ]]; then
  SINGULAR_BASE="${SINGULAR_BASE%ies}y"
elif [[ "$SINGULAR_BASE" =~ s$ ]]; then
  SINGULAR_BASE="${SINGULAR_BASE%?}"
fi

SINGULAR_CAPITALIZED="$(tr '[:lower:]' '[:upper:]' <<< ${SINGULAR_BASE:0:1})${SINGULAR_BASE:1}"

# CLASS_NAME is the plural label used for UI; define entity and model classes
CLASS_NAME="$PLURAL_CAPITALIZED"
ENTITY_NAME="$SINGULAR_CAPITALIZED"
MODEL_CLASS="${ENTITY_NAME}Model"
REQUEST_CLASS="${ENTITY_NAME}Request"
FORM_CLASS="${ENTITY_NAME}Form"
CARD_CLASS="${ENTITY_NAME}Card"

MODULE_DIR="lib/features/$MODULE_NAME_LOWER"
MODEL_FILE="$MODULE_DIR/models/${MODULE_NAME_LOWER}_model.dart"
REQUEST_FILE="$MODULE_DIR/models/${MODULE_NAME_LOWER}_request.dart"
WIDGETS_DIR="$MODULE_DIR/widgets"
SCREEN_DIR="$MODULE_DIR/screens"
MODULE_FILE="$MODULE_DIR/${MODULE_NAME_LOWER}_module.dart"

# create folders
mkdir -p "$MODULE_DIR/models" "$WIDGETS_DIR" "$SCREEN_DIR" "$MODULE_DIR/data" "$MODULE_DIR/bloc" "$MODULE_DIR/api"

# MODEL
cat > "$MODEL_FILE" <<EOF
import 'dart:convert';

class ${MODEL_CLASS} {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int? userId;

  const ${MODEL_CLASS}({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
    this.userId,
  });

  factory ${MODEL_CLASS}.fromJson(Map<String, dynamic> json) {
    return ${MODEL_CLASS}(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      userId: (json['userId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tags': tags,
      'userId': userId,
    };
  }
}
EOF

# REQUEST
cat > "$REQUEST_FILE" <<EOF
class ${REQUEST_CLASS} {
  final String title;
  final String body;
  final List<String> tags;
  final int userId;

  const ${REQUEST_CLASS}({
    required this.title,
    required this.body,
    this.tags = const [],
    this.userId = 1,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'tags': tags,
        'userId': userId,
      };
}
EOF

# FORM widget
cat > "$WIDGETS_DIR/${MODULE_NAME_LOWER}_form.dart" <<EOF
import 'package:flutter/material.dart';

import '../models/${MODULE_NAME_LOWER}_model.dart';
import '../models/${MODULE_NAME_LOWER}_request.dart';

class ${FORM_CLASS} extends StatefulWidget {
  final ${MODEL_CLASS}? initialModel;
  final ValueChanged<${REQUEST_CLASS}> onSubmit;

  const ${FORM_CLASS}({Key? key, this.initialModel, required this.onSubmit}) : super(key: key);

  @override
  State<${FORM_CLASS}> createState() => _${FORM_CLASS}State();
}

class _${FORM_CLASS}State extends State<${FORM_CLASS}> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialModel?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.initialModel?.body ?? '');
    _tagsCtrl = TextEditingController(text: widget.initialModel?.tags.join(', ') ?? '');
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
    final tags = _tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final req = ${REQUEST_CLASS}(
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
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
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(labelText: 'Body'),
            maxLines: 4,
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'Body is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(labelText: 'Tags', hintText: 'Comma separated'),
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
EOF

# CARD widget
cat > "$WIDGETS_DIR/${MODULE_NAME_LOWER}_card.dart" <<EOF
import 'package:flutter/material.dart';

import '../models/${MODULE_NAME_LOWER}_model.dart';

class ${CARD_CLASS} extends StatelessWidget {
  final ${MODEL_CLASS} item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ${CARD_CLASS}({Key? key, required this.item, this.onEdit, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleMedium)),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(item.body),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# SCREEN (list + form usage)
cat > "$SCREEN_DIR/${MODULE_NAME_LOWER}_screen.dart" <<EOF
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/paginated_crud_bloc.dart';
import '../../../core/widgets/paginated_list_view.dart';
import '../../../core/widgets/search_input.dart';
import '../../../core/widgets/sort_selector.dart';
import '../models/${MODULE_NAME_LOWER}_model.dart';
import '../models/${MODULE_NAME_LOWER}_request.dart';
import '../widgets/${MODULE_NAME_LOWER}_card.dart';
import '../widgets/${MODULE_NAME_LOWER}_form.dart';

class ${CLASS_NAME}Screen extends StatefulWidget {
  const ${CLASS_NAME}Screen({Key? key}) : super(key: key);

  @override
  State<${CLASS_NAME}Screen> createState() => _${CLASS_NAME}ScreenState();
}

class _${CLASS_NAME}ScreenState extends State<${CLASS_NAME}Screen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  final List<String> _searchFields = ['title'];
  final List<String> _sortFields = ['id', 'title'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int> get _bloc =>
      context.read<CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>>();

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _bloc.add(SearchItemsEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(
        value,
        searchFields: _searchFields,
      ));
    });
  }

  void _onSort(String field, bool ascending) {
    _bloc.add(SortItemsEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(field, ascending: ascending));
  }

  Future<void> _onRefresh() async {
    _bloc.add(const LoadItemsEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(refresh: true));
  }

  void _openCreate() => _openForm();
  void _openEdit(${MODEL_CLASS} model) => _openForm(initialModel: model, id: model.id);

  void _openForm({${MODEL_CLASS}? initialModel, int? id}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 24),
        child: SingleChildScrollView(
          child: ${FORM_CLASS}(
            initialModel: initialModel,
            onSubmit: (req) {
              Navigator.of(ctx).pop();
              if (id == null) {
                _bloc.add(CreateItemEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(req));
              } else {
                _bloc.add(UpdateItemEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(id, req));
              }
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(${MODEL_CLASS} model) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
            content: Text('Are you sure you want to delete "\${model.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); _bloc.add(DeleteItemEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(model.id)); }, child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>, CrudState<${MODEL_CLASS}>>(
      listener: (ctx, state) {
        final message = state.feedbackMessage;
        if (message != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
          (ctx.read<CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>>() as CrudBloc).add(const ClearFeedbackEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('${CLASS_NAME}')),
        floatingActionButton: FloatingActionButton(onPressed: _openCreate, child: const Icon(Icons.add)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(child: ReusableSearchInput(controller: _searchCtrl, toSearch: _searchFields, onChanged: _onSearch, hintText: 'Search')),
                  BlocBuilder<CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>, CrudState<${MODEL_CLASS}>>(builder: (ctx, state) => SortSelector(sortFields: _sortFields, currentSortBy: state.sortBy, isAscending: state.sortAscending, onSortChanged: _onSort)),
                ],
              ),
            ),
            BlocBuilder<CrudBloc<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>, CrudState<${MODEL_CLASS}>>(builder: (ctx, state) {
              if (state.status == CrudStatus.loading && state.items.isEmpty) return const Center(child: CircularProgressIndicator());
              if (state.status == CrudStatus.failure && state.items.isEmpty) return _ErrorView(message: state.errorMessage ?? 'Unable to load', onRetry: () => _bloc.add(const LoadItemsEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(refresh: true)));

              return Expanded(child: PaginatedListView<${MODEL_CLASS}>(
                items: state.items,
                hasMore: state.hasMore,
                isLoadingMore: state.isLoadingMore,
                onLoadMore: state.hasMore ? () => _bloc.add(const LoadMoreItemsEvent<${REQUEST_CLASS}, ${REQUEST_CLASS}, int>()) : null,
                onRefresh: _onRefresh,
                itemBuilder: (ctx, item, index) => ${CARD_CLASS}(item: item, onEdit: () => _openEdit(item), onDelete: () => _confirmDelete(item)),
                emptyState: Center(child: Text('No ${MODULE_NAME_LOWER} yet')),
              ));
            }),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({Key? key, required this.message, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
EOF

# MODULE ENTRY
cat > "$MODULE_FILE" <<EOF
import 'package:flutter/material.dart';
import '../../core/modules/crud_module.dart';
import '../models/${MODULE_NAME_LOWER}_model.dart';
import '../models/${MODULE_NAME_LOWER}_request.dart';
import 'screens/${MODULE_NAME_LOWER}_screen.dart';

class ${CLASS_NAME}Module {
  static Widget route() {
    return CrudModule.route<${MODEL_CLASS}, ${REQUEST_CLASS}, ${REQUEST_CLASS}, int>(
      child: const ${CLASS_NAME}Screen(),
      fromJson: ${MODEL_CLASS}.fromJson,
      toJson: (x) => x.toJson(),
      idSelectorFn: (x) => x.id,
      baseEndpoint: EndPoints.${MODULE_NAME_LOWER},
      createEndpoint: EndPoints.${MODULE_NAME_LOWER}Add,
      updateEndpointPrefix: EndPoints.${MODULE_NAME_LOWER},
      itemsKey: '${MODULE_NAME_LOWER}',
      createMapper: (r) => r.toJson(),
      updateMapper: (r) => r.toJson(),
    );
  }
}
EOF

# Done
echo "✅ CRUD module '$MODULE_NAME_LOWER' created at $MODULE_DIR. You will likely need to add endpoints to lib/core/network/api_urls.dart and adjust fields in the generated model/request files to match your API."

exit 0
