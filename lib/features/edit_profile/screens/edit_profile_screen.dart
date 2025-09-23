import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/edit_profile_state.dart';
import '../widgets/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          if (state is EditProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EditProfileLoaded) {
            return EditProfileForm(profile: state.profile);
          } else if (state is EditProfileError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Load your profile"));
        },
      ),
    );
  }
}
