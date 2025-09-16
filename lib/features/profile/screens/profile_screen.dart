import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return ProfileView(profile: state.profile);
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(FetchProfile());
              },
              child: const Text("Load Profile"),
            ),
          );
        },
      ),
    );
  }
}
