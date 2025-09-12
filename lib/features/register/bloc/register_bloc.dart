import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../data/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;

  RegisterBloc(this.repository) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    final ApiResponse<Map<String, dynamic>> response =
        await repository.register(event.request);

    if (response.data != null && response.statusCode == 201) {
      emit(RegisterSuccess(response.data!));
    } else {
      emit(RegisterFailure(response.errorMessage ?? "Registration failed"));
    }
  }
}
