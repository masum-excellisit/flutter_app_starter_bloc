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
  final Widget? separator;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? scrollController;

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
    this.separator,
    this.physics,
    this.shrinkWrap = false,
    this.scrollController,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late final ScrollController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _controller = widget.scrollController!;
    } else {
      _controller = ScrollController();
      _isInternalController = true;
    }
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (_isInternalController) {
      _controller.dispose();
    }
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

    if (list.isEmpty && !widget.isLoadingMore) {
      return widget.emptyState ?? const Center(child: Text('No items found.'));
    }

    Widget child = ListView.separated(
      controller: _controller,
      padding: widget.padding ?? const EdgeInsets.all(16),
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
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
      separatorBuilder: (_, __) =>
          widget.separator ?? const SizedBox(height: 12),
      itemCount: list.length + (widget.isLoadingMore && widget.hasMore ? 1 : 0),
    );

    if (widget.onRefresh != null) {
      child = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: child,
      );
    }

    return child;
  }
}
