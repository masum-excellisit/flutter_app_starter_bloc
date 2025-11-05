import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_helpers.dart';
import '../../../core/utils/storage_service.dart';
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
        print("Access Token: ${res.data!.accessToken}");
        print("Refresh Token: ${res.data!.refreshToken}");
        await StorageService.saveTokens(
            res.data!.accessToken, res.data!.refreshToken);
        // Save full user directly from model
        await StorageService.saveUserData(res.data!.toJson());

// Fetch later
        print("User ID: ${await StorageService.getUserData('id')}");
        print("Username: ${await StorageService.getUserData('username')}");
        print(
            "Access Token: ${await StorageService.getUserData('accessToken')}");
      } else {
        emit(LoginFailure(res.errorMessage ?? "Something went wrong"));
      }
    });
  }
}
