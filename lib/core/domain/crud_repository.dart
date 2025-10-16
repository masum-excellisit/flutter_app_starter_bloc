import '../models/paginated_result.dart';

abstract class CrudRepository<T, CreatePayload, UpdatePayload, Id> {
  Future<PaginatedResult<T>> fetchPage({
    required int page,
    required int pageSize,
    String? search,
  });

  Future<T> create(CreatePayload payload);

  Future<T> update(Id id, UpdatePayload payload);

  Future<void> delete(Id id);

  Future<void> cacheItems(List<T> items);

  Future<List<T>> getCachedItems();
}
