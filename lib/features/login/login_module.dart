import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import 'api/login_api.dart';
import 'data/login_repository.dart';
import 'bloc/login_bloc.dart';
import 'screens/login_screen.dart';

class LoginModule {
  static Widget route() {
    final apiClient = ApiClient();
    final api = LoginApi(apiClient);
    final repo = LoginRepository(api);

    return BlocProvider(
      create: (_) => LoginBloc(repo),
      child: const LoginScreen(),
    );
  }
}
