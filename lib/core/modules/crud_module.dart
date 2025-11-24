import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/generic_api.dart';
import '../data/generic_local_data_source.dart';
import '../data/generic_repository.dart';
import '../network/api_client.dart';
import '../bloc/paginated_crud_bloc.dart';
import '../domain/crud_repository.dart';

/// Helper to build a working CRUD Bloc provider for any model T. The consumer
/// must supply serialization/deserialization functions and endpoints.
class CrudModule {
  /// Build a configured `GenericRepository` instance for convenience. This
  /// can be used for manual wiring or testing.
  static GenericRepository<T, CreatePayload, UpdatePayload, Id>
      buildRepository<T, CreatePayload, UpdatePayload, Id>({
    required ApiClient apiClient,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T item) toJson,
    required Id Function(T item) idSelectorFn,
    required String baseEndpoint,
    required String createEndpoint,
    required String updateEndpointPrefix,
    String itemsKey = 'items',
    Map<String, dynamic> Function(CreatePayload)? createMapper,
    Map<String, dynamic> Function(UpdatePayload)? updateMapper,
  }) {
    final genericApi = GenericApi<T, CreatePayload, UpdatePayload, Id>(
      apiClient,
      baseEndpoint: baseEndpoint,
      itemsKey: itemsKey,
      fromJson: fromJson,
      createMapper: createMapper,
      updateMapper: updateMapper,
    );

    final localDataSource = GenericLocalDataSource<T, Id>(
      tableName: baseEndpoint.replaceAll('/', '_'),
      idSelector: idSelectorFn,
      fromJson: fromJson,
      toJson: toJson,
    );

    return GenericRepository<T, CreatePayload, UpdatePayload, Id>(
      api: genericApi,
      localDataSource: localDataSource,
      baseEndpoint: baseEndpoint,
      createEndpoint: createEndpoint,
      updateEndpointPrefix: updateEndpointPrefix,
    );
  }

  /// Builds a widget wrapped with a `CrudBloc` for the given model and
  /// configuration. This allows reuse for any new module by only providing
  /// `fromJson`, `toJson`, `idSelector`, endpoint strings, and optional
  /// mappers for create/update payloads.
  static Widget route<T, CreatePayload, UpdatePayload, Id>({
    required Widget child,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T item) toJson,
    required Id Function(T item) idSelectorFn,
    required String baseEndpoint,
    required String createEndpoint,
    required String updateEndpointPrefix,
    String itemsKey = 'items',
    Map<String, dynamic> Function(CreatePayload)? createMapper,
    Map<String, dynamic> Function(UpdatePayload)? updateMapper,
    bool enableOptimisticUpdates = false,
    List<T> Function(List<T> items, T newItem)? insertItem,
    T Function(T current, T updated)? updateMerger,
    int pageSize = 10,
    String? Function(T, String)? itemSearchFilterSingle,
    bool Function(T, String, List<String>?)? itemSearchFilter,
  }) {
    final apiClient = ApiClient();
    final repository = buildRepository<T, CreatePayload, UpdatePayload, Id>(
      apiClient: apiClient,
      fromJson: fromJson,
      toJson: toJson,
      idSelectorFn: idSelectorFn,
      baseEndpoint: baseEndpoint,
      createEndpoint: createEndpoint,
      updateEndpointPrefix: updateEndpointPrefix,
      itemsKey: itemsKey,
      createMapper: createMapper,
      updateMapper: updateMapper,
    );

    return BlocProvider<CrudBloc<T, CreatePayload, UpdatePayload, Id>>(
      create: (_) {
        final bloc = CrudBloc<T, CreatePayload, UpdatePayload, Id>(
          repository: repository,
          idSelector: (T item) => idSelectorFn(item) as Object,
          insertItem: insertItem,
          updateMerger: updateMerger,
          pageSize: pageSize,
          itemSearchFilter: itemSearchFilter,
          enableOptimisticUpdates: enableOptimisticUpdates,
        );
        // trigger initial fetch as modules used to do
        bloc.add(
            LoadItemsEvent<CreatePayload, UpdatePayload, Id>(refresh: true));
        return bloc;
      },
      child: child,
    );
  }

  /// Like [route] but allows the caller to create their own Bloc type (e.g.
  /// a domain-specific `PostsBloc`) that consumes the `CrudRepository`.
  static Widget routeWithBloc<B extends Bloc<dynamic, CrudState<T>>, T,
      CreatePayload, UpdatePayload, Id>({
    required Widget child,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T item) toJson,
    required Id Function(T item) idSelectorFn,
    required String baseEndpoint,
    required String createEndpoint,
    required String updateEndpointPrefix,
    String itemsKey = 'items',
    Map<String, dynamic> Function(CreatePayload)? createMapper,
    Map<String, dynamic> Function(UpdatePayload)? updateMapper,
    bool enableOptimisticUpdates = false,
    List<T> Function(List<T> items, T newItem)? insertItem,
    T Function(T current, T updated)? updateMerger,
    int pageSize = 10,
    String? Function(T, String)? itemSearchFilterSingle,
    bool Function(T, String, List<String>?)? itemSearchFilter,
    required B Function(CrudRepository<T, CreatePayload, UpdatePayload, Id>)
        blocFactory,
  }) {
    final apiClient = ApiClient();
    final repository = buildRepository<T, CreatePayload, UpdatePayload, Id>(
      apiClient: apiClient,
      fromJson: fromJson,
      toJson: toJson,
      idSelectorFn: idSelectorFn,
      baseEndpoint: baseEndpoint,
      createEndpoint: createEndpoint,
      updateEndpointPrefix: updateEndpointPrefix,
      itemsKey: itemsKey,
      createMapper: createMapper,
      updateMapper: updateMapper,
    );

    return BlocProvider<B>(
      create: (_) {
        final bloc = blocFactory(repository);
        if (bloc is CrudBloc<T, CreatePayload, UpdatePayload, Id>) {
          (bloc as CrudBloc<T, CreatePayload, UpdatePayload, Id>).add(
              LoadItemsEvent<CreatePayload, UpdatePayload, Id>(refresh: true));
        }
        return bloc;
      },
      child: child,
    );
  }
}
