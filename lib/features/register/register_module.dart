import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import 'api/register_api.dart';
import 'data/register_repository.dart';
import 'bloc/register_bloc.dart';
import 'screens/register_screen.dart';

class RegisterModule {
  static Widget route() {
    final apiClient = ApiClient();
    final api = RegisterApi(apiClient);
    final repo = RegisterRepository(api);

    return BlocProvider(
      create: (_) => RegisterBloc(repo),
      child: const RegisterScreen(),
    );
  }
}
