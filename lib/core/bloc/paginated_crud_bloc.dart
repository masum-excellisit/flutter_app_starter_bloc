import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/crud_repository.dart';
import '../models/paginated_result.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

enum CrudStatus { initial, loading, success, failure }

enum CrudOperation { none, create, update, delete, bulkDelete }

abstract class CrudEvent<CreatePayload, UpdatePayload, Id> extends Equatable {
  const CrudEvent();
}

class LoadItemsEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final bool refresh;
  final String? search;

  const LoadItemsEvent({this.refresh = false, this.search});

  @override
  List<Object?> get props => [refresh, search];
}

class LoadMoreItemsEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  const LoadMoreItemsEvent();

  @override
  List<Object?> get props => [];
}

class SearchItemsEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final String query;
  final List<String>? searchFields;

  const SearchItemsEvent(this.query, {this.searchFields});

  @override
  List<Object?> get props => [query, searchFields];
}

class CreateItemEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final CreatePayload payload;

  const CreateItemEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class UpdateItemEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final Id id;
  final UpdatePayload payload;

  const UpdateItemEvent(this.id, this.payload);

  @override
  List<Object?> get props => [id, payload];
}

class DeleteItemEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final Id id;

  const DeleteItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearFeedbackEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  const ClearFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class SortItemsEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final String sortBy;
  final bool ascending;

  const SortItemsEvent(this.sortBy, {this.ascending = true});

  @override
  List<Object?> get props => [sortBy, ascending];
}

class BulkDeleteItemsEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  final List<Id> ids;

  const BulkDeleteItemsEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}

class RetryFailedOperationEvent<CreatePayload, UpdatePayload, Id>
    extends CrudEvent<CreatePayload, UpdatePayload, Id> {
  const RetryFailedOperationEvent();

  @override
  List<Object?> get props => [];
}

class CrudState<T> extends Equatable {
  static const Object _unset = Object();

  final CrudStatus status;
  final List<T> items;
  final bool hasMore;
  final bool isOffline;
  final bool isLoadingMore;
  final String? errorMessage;
  final CrudOperation operationInProgress;
  final String? query;
  final String? feedbackMessage;
  final bool feedbackIsError;
  final List<String>? searchFields;
  final String? sortBy;
  final bool sortAscending;
  final Map<String, dynamic>? filters;
  final Failure? lastFailure;
  final int retryCount;
  final bool isRetrying;

  const CrudState({
    this.status = CrudStatus.initial,
    this.items = const [],
    this.hasMore = true,
    this.isOffline = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.operationInProgress = CrudOperation.none,
    this.query,
    this.feedbackMessage,
    this.feedbackIsError = false,
    this.searchFields,
    this.sortBy,
    this.sortAscending = true,
    this.filters,
    this.lastFailure,
    this.retryCount = 0,
    this.isRetrying = false,
  });

  CrudState<T> copyWith({
    CrudStatus? status,
    List<T>? items,
    bool? hasMore,
    bool? isOffline,
    bool? isLoadingMore,
    Object? errorMessage = _unset,
    CrudOperation? operationInProgress,
    String? query,
    Object? feedbackMessage = _unset,
    bool? feedbackIsError,
    List<String>? searchFields,
    String? sortBy,
    bool? sortAscending,
    Map<String, dynamic>? filters,
    Object? lastFailure = _unset,
    int? retryCount,
    bool? isRetrying,
  }) {
    return CrudState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      operationInProgress: operationInProgress ?? this.operationInProgress,
      query: query ?? this.query,
      feedbackMessage: feedbackMessage == _unset
          ? this.feedbackMessage
          : feedbackMessage as String?,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      searchFields: searchFields ?? this.searchFields,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      filters: filters ?? this.filters,
      lastFailure:
          lastFailure == _unset ? this.lastFailure : lastFailure as Failure?,
      retryCount: retryCount ?? this.retryCount,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        hasMore,
        isOffline,
        isLoadingMore,
        errorMessage,
        operationInProgress,
        query,
        feedbackMessage,
        feedbackIsError,
        searchFields,
        sortBy,
        sortAscending,
        filters,
        lastFailure,
        retryCount,
        isRetrying,
      ];
}

class CrudBloc<T, CreatePayload, UpdatePayload, Id>
    extends Bloc<CrudEvent<CreatePayload, UpdatePayload, Id>, CrudState<T>> {
  CrudBloc({
    required CrudRepository<T, CreatePayload, UpdatePayload, Id> repository,
    required Object Function(T item) idSelector,
    List<T> Function(List<T> items, T newItem)? insertItem,
    T Function(T current, T updated)? updateMerger,
    this.pageSize = 20,
    this.itemSearchFilter,
    this.itemSorter,
    this.enableOptimisticUpdates = false,
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 2),
  })  : _repository = repository,
        _idSelector = idSelector,
        _insertItem = insertItem,
        _updateMerger = updateMerger,
        super(CrudState<T>()) {
    on<LoadItemsEvent<CreatePayload, UpdatePayload, Id>>(_onLoadItems);
    on<LoadMoreItemsEvent<CreatePayload, UpdatePayload, Id>>(_onLoadMore);
    on<SearchItemsEvent<CreatePayload, UpdatePayload, Id>>(_onSearch);
    on<CreateItemEvent<CreatePayload, UpdatePayload, Id>>(_onCreateItem);
    on<UpdateItemEvent<CreatePayload, UpdatePayload, Id>>(_onUpdateItem);
    on<DeleteItemEvent<CreatePayload, UpdatePayload, Id>>(_onDeleteItem);
    on<ClearFeedbackEvent<CreatePayload, UpdatePayload, Id>>(_onClearFeedback);
    on<SortItemsEvent<CreatePayload, UpdatePayload, Id>>(_onSortItems);
    on<BulkDeleteItemsEvent<CreatePayload, UpdatePayload, Id>>(_onBulkDelete);
    on<RetryFailedOperationEvent<CreatePayload, UpdatePayload, Id>>(_onRetry);
  }

  final CrudRepository<T, CreatePayload, UpdatePayload, Id> _repository;
  final Object Function(T item) _idSelector;
  final List<T> Function(List<T> items, T newItem)? _insertItem;
  final T Function(T current, T updated)? _updateMerger;
  final int pageSize;
  final bool Function(T item, String query, List<String>? fields)?
      itemSearchFilter;
  final int Function(T a, T b, String sortBy)? itemSorter;
  final bool enableOptimisticUpdates;
  final int maxRetryAttempts;
  final Duration retryDelay;

  bool _isFetching = false;
  int _page = 0;
  String? _currentQuery;
  List<String>? _currentSearchFields;
  String? _currentSortBy;
  bool _currentSortAscending = true;
  CrudEvent<CreatePayload, UpdatePayload, Id>? _lastFailedEvent;

  Future<void> _onLoadItems(
    LoadItemsEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    await _fetchPage(emit, refresh: event.refresh, search: event.search);
  }

  Future<void> _onLoadMore(
    LoadMoreItemsEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    await _fetchPage(emit, refresh: false, search: _currentQuery);
  }

  Future<void> _onSearch(
    SearchItemsEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    _currentQuery = event.query.trim().isEmpty ? null : event.query.trim();
    _currentSearchFields = event.searchFields;
    await _fetchPage(
      emit,
      refresh: true,
      search: _currentQuery,
      searchFields: _currentSearchFields,
    );
  }

  Future<void> _fetchPage(
    Emitter<CrudState<T>> emit, {
    required bool refresh,
    String? search,
    List<String>? searchFields,
    String? sortBy,
    bool? sortAscending,
  }) async {
    if (_isFetching) {
      return;
    }

    final targetQuery = search ?? _currentQuery;
    final targetFields = searchFields ?? _currentSearchFields;
    final targetSortBy = sortBy ?? _currentSortBy;
    final targetSortAscending = sortAscending ?? _currentSortAscending;

    if (refresh) {
      _page = 0;
    } else if (!state.hasMore) {
      return;
    }

    final bool isInitialPage = _page == 0;
    _isFetching = true;

    if (isInitialPage) {
      emit(state.copyWith(
        status: CrudStatus.loading,
        query: targetQuery,
        searchFields: targetFields,
        sortBy: targetSortBy,
        sortAscending: targetSortAscending,
        isOffline: false,
        errorMessage: CrudState._unset,
        feedbackMessage: CrudState._unset,
      ));
    } else {
      emit(state.copyWith(
        isLoadingMore: true,
        query: targetQuery,
        searchFields: targetFields,
        sortBy: targetSortBy,
        sortAscending: targetSortAscending,
        isOffline: false,
        errorMessage: CrudState._unset,
        feedbackMessage: CrudState._unset,
      ));
    }

    try {
      final PaginatedResult<T> result = await _repository.fetchPage(
        page: _page,
        pageSize: pageSize,
        search: targetQuery,
        sortBy: targetSortBy,
        sortOrder: targetSortAscending ? 'asc' : 'desc',
      );

      List<T> filteredItems = result.items;

      // Apply client-side filtering if searchFields are specified
      if (targetQuery != null &&
          targetQuery.isNotEmpty &&
          targetFields != null &&
          targetFields.isNotEmpty &&
          itemSearchFilter != null) {
        filteredItems = result.items
            .where((item) => itemSearchFilter!(item, targetQuery, targetFields))
            .toList();
      }

      final List<T> updatedItems =
          _page == 0 ? filteredItems : <T>[...state.items, ...filteredItems];

      await _repository.cacheItems(updatedItems);

      _currentQuery = targetQuery;
      _currentSearchFields = targetFields;
      _currentSortBy = targetSortBy;
      _currentSortAscending = targetSortAscending;
      _page += 1;

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        hasMore: result.hasMore,
        isOffline: false,
        isLoadingMore: false,
        errorMessage: CrudState._unset,
        query: targetQuery,
        searchFields: targetFields,
        sortBy: targetSortBy,
        sortAscending: targetSortAscending,
      ));
    } catch (error) {
      final failure = _handleError(error);

      if (_page == 0) {
        try {
          final List<T> cachedItems = await _repository.getCachedItems();
          if (cachedItems.isNotEmpty) {
            emit(state.copyWith(
              status: CrudStatus.success,
              items: cachedItems,
              hasMore: false,
              isOffline: true,
              isLoadingMore: false,
              errorMessage: failure.message,
              lastFailure: failure,
            ));
            _isFetching = false;
            return;
          }
        } catch (_) {}
      }

      emit(state.copyWith(
        status: CrudStatus.failure,
        isLoadingMore: false,
        errorMessage: failure.message,
        lastFailure: failure,
      ));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onSortItems(
    SortItemsEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    // Trigger API call with sort parameters
    await _fetchPage(
      emit,
      refresh: true,
      sortBy: event.sortBy,
      sortAscending: event.ascending,
    );
  }

  Future<void> _onBulkDelete(
    BulkDeleteItemsEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    if (event.ids.isEmpty) return;

    emit(state.copyWith(
      operationInProgress: CrudOperation.bulkDelete,
      feedbackMessage: CrudState._unset,
    ));

    try {
      final updatedItems = state.items
          .where((item) => !event.ids.contains(_idSelector(item) as Id))
          .toList();

      if (enableOptimisticUpdates) {
        emit(state.copyWith(items: updatedItems));
      }

      for (final id in event.ids) {
        await _repository.delete(id);
      }

      await _repository.cacheItems(updatedItems);

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        operationInProgress: CrudOperation.none,
        feedbackMessage: 'Deleted ${event.ids.length} item(s) successfully',
        feedbackIsError: false,
      ));
    } catch (error) {
      final failure = _handleError(error);
      _lastFailedEvent = event;

      emit(state.copyWith(
        operationInProgress: CrudOperation.none,
        feedbackMessage: failure.message,
        feedbackIsError: true,
        lastFailure: failure,
      ));
    }
  }

  Future<void> _onRetry(
    RetryFailedOperationEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    if (_lastFailedEvent == null || state.retryCount >= maxRetryAttempts) {
      return;
    }

    emit(state.copyWith(
      isRetrying: true,
      retryCount: state.retryCount + 1,
    ));

    await Future.delayed(retryDelay * (state.retryCount + 1));

    add(_lastFailedEvent!);

    emit(state.copyWith(isRetrying: false));
  }

  Failure _handleError(dynamic error) {
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }
    if (error is CacheException) {
      return CacheFailure(error.message);
    }
    if (error is ValidationException) {
      return ValidationFailure(error.message);
    }
    if (error is AuthException) {
      return AuthFailure(error.message);
    }
    if (error.toString().contains('SocketException')) {
      return const NetworkFailure(
          'No internet connection. Please check your network.');
    }
    return UnknownFailure('An unexpected error occurred: ${error.toString()}');
  }

  @override
  Future<void> _onCreateItem(
    CreateItemEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    emit(state.copyWith(
      operationInProgress: CrudOperation.create,
      feedbackMessage: CrudState._unset,
      lastFailure: CrudState._unset,
    ));

    try {
      final T created = await _repository.create(event.payload);
      final List<T> updatedItems;
      final insert = _insertItem;
      if (insert != null) {
        updatedItems = insert(state.items, created);
      } else {
        updatedItems = <T>[created, ...state.items];
      }

      await _repository.cacheItems(updatedItems);

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        operationInProgress: CrudOperation.none,
        feedbackMessage: 'Created successfully',
        feedbackIsError: false,
        retryCount: 0,
      ));
      _lastFailedEvent = null;
    } catch (error) {
      final failure = _handleError(error);
      _lastFailedEvent = event;

      emit(state.copyWith(
        operationInProgress: CrudOperation.none,
        feedbackMessage: failure.message,
        feedbackIsError: true,
        lastFailure: failure,
      ));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItemEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    emit(state.copyWith(
      operationInProgress: CrudOperation.update,
      feedbackMessage: CrudState._unset,
    ));

    try {
      final T updated = await _repository.update(event.id, event.payload);
      final List<T> updatedItems = state.items.map((T item) {
        if (_idSelector(item) == event.id) {
          final merger = _updateMerger;
          return merger != null ? merger(item, updated) : updated;
        }
        return item;
      }).toList();

      await _repository.cacheItems(updatedItems);

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        operationInProgress: CrudOperation.none,
        feedbackMessage: 'Updated successfully',
        feedbackIsError: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        operationInProgress: CrudOperation.none,
        feedbackMessage: error.toString(),
        feedbackIsError: true,
      ));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItemEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    emit(state.copyWith(
      operationInProgress: CrudOperation.delete,
      feedbackMessage: CrudState._unset,
    ));

    try {
      await _repository.delete(event.id);
      final List<T> updatedItems =
          state.items.where((T item) => _idSelector(item) != event.id).toList();

      await _repository.cacheItems(updatedItems);

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        operationInProgress: CrudOperation.none,
        feedbackMessage: 'Deleted successfully',
        feedbackIsError: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        operationInProgress: CrudOperation.none,
        feedbackMessage: error.toString(),
        feedbackIsError: true,
      ));
    }
  }

  Future<void> _onClearFeedback(
    ClearFeedbackEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    if (state.feedbackMessage != null) {
      emit(state.copyWith(feedbackMessage: null));
    }
  }
}
