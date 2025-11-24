// dart:io and dio imports aren't needed; this is a wrapper around ApiClient which already depends on dio.
import '../models/paginated_result.dart';
import '../network/api_client.dart';
import '../network/api_response.dart';

/// Generic API wrapper for CRUD/paginated operations for any model type T.
class GenericApi<T, CreatePayload, UpdatePayload, Id> {
  final ApiClient _client;
  final String baseEndpoint;
  final String itemsKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(CreatePayload)? createMapper;
  final Map<String, dynamic> Function(UpdatePayload)? updateMapper;

  GenericApi(
    this._client, {
    required this.baseEndpoint,
    this.itemsKey = 'items',
    required this.fromJson,
    this.createMapper,
    this.updateMapper,
  });

  Future<ApiResponse<PaginatedResult<T>>> fetchPage({
    required int page,
    required int pageSize,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? queryParamKey,
  }) {
    final bool hasQuery = search != null && search.isNotEmpty;
    final endpoint = hasQuery ? '$baseEndpoint/search' : baseEndpoint;

    final int skip = page * pageSize;
    final queryParameters = <String, dynamic>{
      'limit': pageSize,
      'skip': skip,
      if (hasQuery) (queryParamKey ?? 'q'): search,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder.isNotEmpty) 'order': sortOrder,
    };

    return _client.getRequest<PaginatedResult<T>>(
      endPoint: endpoint,
      queryParameters: queryParameters,
      fromJson: (Map<String, dynamic> json) {
        final List<dynamic> listJson =
            json[itemsKey] as List<dynamic>? ?? const [];
        final int total = (json['total'] as num?)?.toInt() ?? listJson.length;
        final int limit = (json['limit'] as num?)?.toInt() ?? pageSize;
        final int currentSkip = (json['skip'] as num?)?.toInt() ?? skip;
        final int currentPage = limit == 0 ? 0 : currentSkip ~/ limit;

        final items = listJson
            .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        return PaginatedResult<T>(
          items: items,
          total: total,
          page: currentPage,
          pageSize: limit,
        );
      },
    );
  }

  Future<ApiResponse<T>> create(CreatePayload payload, String endpoint) {
    if (createMapper == null) {
      throw Exception('No createMapper provided for GenericApi.create');
    }
    final model = createMapper!(payload);
    return _client.postRequest<T>(
      endPoint: endpoint,
      reqModel: model,
      fromJson: (Map<String, dynamic> json) => fromJson(json),
    );
  }

  Future<ApiResponse<T>> update(
      Id id, UpdatePayload payload, String endpointPrefix) {
    if (updateMapper == null) {
      throw Exception('No updateMapper provided for GenericApi.update');
    }
    final model = updateMapper!(payload);
    final endPoint = '$endpointPrefix/$id';
    return _client.putRequest<T>(
      endPoint: endPoint,
      reqModel: model,
      fromJson: (Map<String, dynamic> json) => fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
      Id id, String endpointPrefix) {
    final endPoint = '$endpointPrefix/$id';
    return _client.deleteRequest(endPoint: endPoint);
  }
}
