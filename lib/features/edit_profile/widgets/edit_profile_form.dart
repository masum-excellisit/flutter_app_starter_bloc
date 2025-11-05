import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/edit_profile_bloc.dart';
import '../bloc/edit_profile_event.dart';
import '../model/edit_profile_request.dart';
import '../model/edit_profile_response.dart';

class EditProfileForm extends StatefulWidget {
  final EditProfileResponse profile;
  const EditProfileForm({super.key, required this.profile});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.firstName);
    emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "First Name")),
          const SizedBox(height: 20),
          TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final request = EditProfileRequest(
                firstName: nameController.text,
                email: emailController.text,
              );
              context.read<EditProfileBloc>().add(UpdateProfileEvent(request));
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
