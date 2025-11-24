import '../domain/crud_repository.dart';
import '../network/generic_api.dart';
import 'generic_local_data_source.dart';
import '../models/paginated_result.dart';
import '../network/api_response.dart';
import '../errors/exceptions.dart';

class GenericRepository<T, CreatePayload, UpdatePayload, Id>
    implements CrudRepository<T, CreatePayload, UpdatePayload, Id> {
  final GenericApi<T, CreatePayload, UpdatePayload, Id> api;
  final GenericLocalDataSource<T, Id> localDataSource;
  final String baseEndpoint;
  final String createEndpoint;
  final String updateEndpointPrefix;

  GenericRepository({
    required this.api,
    required this.localDataSource,
    required this.baseEndpoint,
    required this.createEndpoint,
    required this.updateEndpointPrefix,
  });

  @override
  @override
  Future<void> cacheItems(List<T> items) async {
    await localDataSource.cacheItems(items);
  }

  @override
  @override
  Future<void> delete(Id id) async {
    final ApiResponse<Map<String, dynamic>> response =
        await api.delete(id, updateEndpointPrefix);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ServerException(response.errorMessage ?? 'Failed to delete item',
        statusCode: response.statusCode);
  }

  @override
  @override
  Future<T> create(CreatePayload payload) async {
    final ApiResponse<T> response = await api.create(payload, createEndpoint);
    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.errorMessage ?? 'Failed to create item',
        statusCode: response.statusCode);
  }

  @override
  @override
  Future<List<T>> getCachedItems() => localDataSource.getCachedItems();

  @override
  @override
  Future<PaginatedResult<T>> fetchPage({
    required int page,
    required int pageSize,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await api.fetchPage(
      page: page,
      pageSize: pageSize,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw ServerException(response.errorMessage ?? 'Failed to load items',
        statusCode: response.statusCode);
  }

  @override
  @override
  Future<T> update(Id id, UpdatePayload payload) async {
    final response = await api.update(id, payload, updateEndpointPrefix);
    if (response.data != null) {
      return response.data!;
    }
    throw ServerException(response.errorMessage ?? 'Failed to update item',
        statusCode: response.statusCode);
  }
}
