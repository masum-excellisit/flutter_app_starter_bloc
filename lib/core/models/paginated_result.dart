class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => (page + 1) * pageSize < total;
}
