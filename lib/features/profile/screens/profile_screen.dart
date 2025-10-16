import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when the screen is initialized with post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(FetchProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
          // if (state is ProfileErrorUnauthorized) then redirect to login screen
          else if (state is ProfileErrorUnauthorized) {
            // Using addPostFrameCallback to ensure navigation happens after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed('login');
            });
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(FetchProfile());
              },
              child: const Text("Retry"),
            ),
          );
        },
      ),
    );
  }
}
