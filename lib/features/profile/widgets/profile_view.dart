import 'package:flutter/material.dart';
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
            backgroundImage: NetworkImage(profile.avatar),
          ),
          const SizedBox(height: 16),
          Text(profile.name, style: const TextStyle(fontSize: 20)),
          Text(profile.email, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
