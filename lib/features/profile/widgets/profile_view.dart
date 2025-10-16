import 'package:flutter/material.dart';
import 'package:flutter_app_starter_bloc/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/storage_service.dart';
import '../model/profile_response.dart';

class ProfileView extends StatelessWidget {
  final ProfileResponse profile;

  const ProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profile.image ?? ''),
          ),
          const SizedBox(height: 16),
          Text('${profile.firstName} ${profile.lastName}',
              style: const TextStyle(fontSize: 20)),
          Text(profile.email ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.pushNamed('edit_profile');
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.pushNamed('posts');
            },
            child: const Text('Posts'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearAllData();
              if (!context.mounted) return;
              context.goNamed('login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
