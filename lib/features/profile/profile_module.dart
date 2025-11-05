import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import 'api/profile_api.dart';
import 'data/profile_repository.dart';
import 'bloc/profile_bloc.dart';
import 'screens/profile_screen.dart';

class ProfileModule {
  static Widget route() {
    final apiClient = ApiClient();
    final api = ProfileApi(apiClient);
    final repo = ProfileRepository(api);

    return BlocProvider(
      create: (_) => ProfileBloc(repo),
      child: const ProfileScreen(),
    );
  }
}
