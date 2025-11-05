import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../data/create_product_repository.dart';
import 'create_product_event.dart';
import 'create_product_state.dart';

class CreateProductBloc extends Bloc<CreateProductEvent, CreateProductState> {
  final CreateProductRepository _repository;

  CreateProductBloc(this._repository) : super(const CreateProductState()) {
    on<SubmitProductEvent>(_onSubmit);
    on<ResetFormEvent>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitProductEvent event,
    Emitter<CreateProductState> emit,
  ) async {
    emit(state.copyWith(status: CreateProductStatus.loading));

    try {
      final product = await _repository.createProduct(event.data);
      emit(state.copyWith(
        status: CreateProductStatus.success,
        product: product,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        status: CreateProductStatus.failure,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: CreateProductStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateProductStatus.failure,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _onReset(
    ResetFormEvent event,
    Emitter<CreateProductState> emit,
  ) async {
    emit(const CreateProductState());
  }
}
