import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import 'api/edit_profile_api.dart';
import 'data/edit_profile_repository.dart';
import 'bloc/edit_profile_bloc.dart';
import 'screens/edit_profile_screen.dart';

class Edit_profileModule {
  static Widget route() {
    final apiClient = ApiClient();
    final api = EditProfileApi(apiClient);
    final repo = EditProfileRepository(api);

    return BlocProvider(
      create: (_) => EditProfileBloc(repo),
      child: const EditProfileScreen(),
    );
  }
}
