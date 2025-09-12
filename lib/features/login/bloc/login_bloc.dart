import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../data/login_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repo;

  LoginBloc(this.repo) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      final res = await repo.login(event.username, event.password);
      if (res.statusCode == 400) {
        emit(LoginFailure("Invalid credentials"));
        return;
      }
      if (res.data != null) {
        emit(LoginSuccess(res.data!));
      } else {
        emit(LoginFailure(res.errorMessage ?? "Something went wrong"));
      }
    });
  }
}
