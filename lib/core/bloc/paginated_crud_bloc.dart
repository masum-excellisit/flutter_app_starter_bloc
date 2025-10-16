import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/crud_repository.dart';
import '../models/paginated_result.dart';

enum CrudStatus { initial, loading, success, failure }

enum CrudOperation { none, create, update, delete }

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

  const SearchItemsEvent(this.query);

  @override
  List<Object?> get props => [query];
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
  }

  final CrudRepository<T, CreatePayload, UpdatePayload, Id> _repository;
  final Object Function(T item) _idSelector;
  final List<T> Function(List<T> items, T newItem)? _insertItem;
  final T Function(T current, T updated)? _updateMerger;
  final int pageSize;

  bool _isFetching = false;
  int _page = 0;
  String? _currentQuery;

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
    await _fetchPage(emit, refresh: true, search: _currentQuery);
  }

  Future<void> _fetchPage(
    Emitter<CrudState<T>> emit, {
    required bool refresh,
    String? search,
  }) async {
    if (_isFetching) {
      return;
    }

    final targetQuery = search ?? _currentQuery;
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
        isOffline: false,
        errorMessage: CrudState._unset,
        feedbackMessage: CrudState._unset,
      ));
    } else {
      emit(state.copyWith(
        isLoadingMore: true,
        query: targetQuery,
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
      );
      final List<T> updatedItems =
          _page == 0 ? result.items : <T>[...state.items, ...result.items];

      await _repository.cacheItems(updatedItems);

      _currentQuery = targetQuery;
      _page += 1;

      emit(state.copyWith(
        status: CrudStatus.success,
        items: updatedItems,
        hasMore: result.hasMore,
        isOffline: false,
        isLoadingMore: false,
        errorMessage: CrudState._unset,
        query: targetQuery,
      ));
    } catch (error) {
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
              errorMessage: error.toString(),
            ));
            _isFetching = false;
            return;
          }
        } catch (_) {
          // Ignore cache errors and fall back to failure state.
        }
      }

      emit(state.copyWith(
        status: CrudStatus.failure,
        isLoadingMore: false,
        errorMessage: error.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onCreateItem(
    CreateItemEvent<CreatePayload, UpdatePayload, Id> event,
    Emitter<CrudState<T>> emit,
  ) async {
    emit(state.copyWith(
      operationInProgress: CrudOperation.create,
      feedbackMessage: CrudState._unset,
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
      ));
    } catch (error) {
      emit(state.copyWith(
        operationInProgress: CrudOperation.none,
        feedbackMessage: error.toString(),
        feedbackIsError: true,
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
