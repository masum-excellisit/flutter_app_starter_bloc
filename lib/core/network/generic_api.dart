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
      fromJson: (dynamic json) {
        // The endpoint might return a few different shapes:
        // 1) a wrapper object: { '<itemsKey>': [...], 'total': ..., 'skip': ..., 'limit': ... }
        // 2) a wrapper object with 'items'/'data' fields
        // 3) a top-level List [...]
        // We try a few heuristics to extract the array safely.
        dynamic raw = json;
        List<dynamic> listJson = const [];
        int total = 0;
        int limit = pageSize;
        int currentSkip = skip;

        try {
          if (raw is List) {
            listJson = raw;
            total = listJson.length;
            limit = pageSize;
            currentSkip = skip;
          } else if (raw is Map<String, dynamic>) {
            // prefer the provided itemsKey
            final dynamic itemsCandidate = raw[itemsKey];
            if (itemsCandidate is List) {
              listJson = itemsCandidate;
            } else if ((raw['items'] is List)) {
              listJson = raw['items'] as List<dynamic>;
            } else if ((raw['data'] is List)) {
              listJson = raw['data'] as List<dynamic>;
            } else {
              // Not an array container - try to detect if the response itself is a single item
              listJson = const [];
            }

            total = (raw['total'] as num?)?.toInt() ?? listJson.length;
            limit = (raw['limit'] as num?)?.toInt() ?? pageSize;
            currentSkip = (raw['skip'] as num?)?.toInt() ?? skip;
          }
        } catch (_) {
          listJson = const [];
          total = 0;
          limit = pageSize;
          currentSkip = skip;
        }

        final int currentPage = limit == 0 ? 0 : (currentSkip ~/ limit);

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
