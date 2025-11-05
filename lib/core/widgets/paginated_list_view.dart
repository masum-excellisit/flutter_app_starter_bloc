import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final ItemWidgetBuilder<T> itemBuilder;
  final RefreshCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final Widget? emptyState;
  final EdgeInsetsGeometry? padding;
  final WidgetBuilder? loadingIndicatorBuilder;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.emptyState,
    this.padding,
    this.loadingIndicatorBuilder,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.onLoadMore == null || widget.isLoadingMore) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.items;

    Widget child = ListView.separated(
      controller: _controller,
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        if (index == list.length) {
          return widget.loadingIndicatorBuilder?.call(context) ??
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
        }
        return widget.itemBuilder(context, list[index], index);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: list.length + (widget.isLoadingMore && widget.hasMore ? 1 : 0),
    );

    if (widget.onRefresh != null) {
      child = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: child,
      );
    }

    if (list.isEmpty && !widget.isLoadingMore) {
      return widget.emptyState ?? const Center(child: Text('No items found.'));
    }

    return child;
  }
}
