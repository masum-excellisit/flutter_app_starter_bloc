import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/paginated_crud_bloc.dart';
import '../../../core/widgets/paginated_list_view.dart';
import '../../../core/widgets/search_input.dart';
import '../../../core/widgets/sort_selector.dart';
import '../models/recipes_model.dart';
import '../models/recipes_request.dart';
import '../widgets/recipes_card.dart';
import '../widgets/recipes_form.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  final List<String> _searchFields = ['name'];
  final List<String> _sortFields = ['id', 'name'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int> get _bloc =>
      context.read<CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int>>();

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _bloc.add(SearchItemsEvent<RecipeRequest, RecipeRequest, int>(
        value,
        searchFields: _searchFields,
      ));
    });
  }

  void _onSort(String field, bool ascending) {
    _bloc.add(SortItemsEvent<RecipeRequest, RecipeRequest, int>(field,
        ascending: ascending));
  }

  Future<void> _onRefresh() async {
    _bloc.add(
        const LoadItemsEvent<RecipeRequest, RecipeRequest, int>(refresh: true));
  }

  void _openCreate() => _openForm();
  void _openEdit(RecipeModel model) =>
      _openForm(initialModel: model, id: model.id);

  void _openForm({RecipeModel? initialModel, int? id}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24),
        child: SingleChildScrollView(
          child: RecipeForm(
            initialModel: initialModel,
            onSubmit: (req) {
              Navigator.of(ctx).pop();
              if (id == null) {
                _bloc.add(
                    CreateItemEvent<RecipeRequest, RecipeRequest, int>(req));
              } else {
                _bloc.add(UpdateItemEvent<RecipeRequest, RecipeRequest, int>(
                    id, req));
              }
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(RecipeModel model) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${model.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _bloc.add(DeleteItemEvent<RecipeRequest, RecipeRequest, int>(
                    model.id));
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
        CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int>,
        CrudState<RecipeModel>>(
      listener: (ctx, state) {
        final message = state.feedbackMessage;
        if (message != null) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(message)));
          (ctx.read<CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int>>()
                  as CrudBloc)
              .add(const ClearFeedbackEvent<RecipeRequest, RecipeRequest,
                  int>());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Recipes')),
        floatingActionButton: FloatingActionButton(
            onPressed: _openCreate, child: const Icon(Icons.add)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                      child: ReusableSearchInput(
                          controller: _searchCtrl,
                          toSearch: _searchFields,
                          onChanged: _onSearch,
                          hintText: 'Search')),
                  BlocBuilder<
                          CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int>,
                          CrudState<RecipeModel>>(
                      builder: (ctx, state) => SortSelector(
                          sortFields: _sortFields,
                          currentSortBy: state.sortBy,
                          isAscending: state.sortAscending,
                          onSortChanged: _onSort)),
                ],
              ),
            ),
            BlocBuilder<
                CrudBloc<RecipeModel, RecipeRequest, RecipeRequest, int>,
                CrudState<RecipeModel>>(builder: (ctx, state) {
              if (state.status == CrudStatus.loading && state.items.isEmpty)
                return const Center(child: CircularProgressIndicator());
              if (state.status == CrudStatus.failure && state.items.isEmpty)
                return _ErrorView(
                    message: state.errorMessage ?? 'Unable to load',
                    onRetry: () => _bloc.add(
                        const LoadItemsEvent<RecipeRequest, RecipeRequest, int>(
                            refresh: true)));

              return Expanded(
                  child: PaginatedListView<RecipeModel>(
                items: state.items,
                hasMore: state.hasMore,
                isLoadingMore: state.isLoadingMore,
                onLoadMore: state.hasMore
                    ? () => _bloc.add(const LoadMoreItemsEvent<RecipeRequest,
                        RecipeRequest, int>())
                    : null,
                onRefresh: _onRefresh,
                itemBuilder: (ctx, item, index) => RecipeCard(
                    item: item,
                    onEdit: () => _openEdit(item),
                    onDelete: () => _confirmDelete(item)),
                emptyState: Center(child: Text('No recipes yet')),
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

  const _ErrorView({Key? key, required this.message, required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
