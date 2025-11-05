import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../data/create_post_repository.dart';
import 'create_post_event.dart';
import 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostRepository _repository;

  CreatePostBloc(this._repository) : super(const CreatePostState()) {
    on<SubmitPostEvent>(_onSubmit);
    on<ResetFormEvent>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitPostEvent event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(state.copyWith(status: CreatePostStatus.loading));

    try {
      final post = await _repository.createPost(event.data);
      emit(state.copyWith(
        status: CreatePostStatus.success,
        post: post,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        status: CreatePostStatus.failure,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: CreatePostStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreatePostStatus.failure,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _onReset(
    ResetFormEvent event,
    Emitter<CreatePostState> emit,
  ) async {
    emit(const CreatePostState());
  }
}
