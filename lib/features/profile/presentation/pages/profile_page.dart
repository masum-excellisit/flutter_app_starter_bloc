import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../injection_container.dart' as di;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _editing = false;
  Profile? _currentProfile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    setState(() {
      _editing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editing = false;
      if (_currentProfile != null) {
        _nameController.text = _currentProfile!.name;
        _emailController.text = _currentProfile!.email;
      }
    });
  }

  void _save(BuildContext context) {
    if (_currentProfile == null) return;
    final updated = Profile(
      id: _currentProfile!.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
    context.read<ProfileBloc>().add(UpdateProfile(profile: updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Profile'),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              // Update controllers with latest data, exit edit mode after save
              _currentProfile = state.profile;
              _nameController.text = state.profile.name;
              _emailController.text = state.profile.email;
              _editing = false;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const LoadingWidget(message: 'Loading profile...');
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;
              // Ensure controllers are populated when first loaded
              if (_currentProfile == null) {
                _currentProfile = profile;
                _nameController.text = profile.name;
                _emailController.text = profile.email;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'User ID: ${profile.id}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textHint),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          CustomTextField(
                            label: 'Name',
                            controller: _nameController,
                            enabled: _editing,
                          ),
                          const SizedBox(height: AppSizes.sm),
                          CustomTextField(
                            label: 'Email',
                            controller: _emailController,
                            enabled: _editing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    if (!_editing) ...[
                      CustomButton(
                        text: 'Edit',
                        onPressed: _enterEditMode,
                        icon: Icons.edit,
                        width: double.infinity,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancel',
                              isOutlined: true,
                              onPressed: _cancelEdit,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: CustomButton(
                              text: 'Save',
                              onPressed: () => _save(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }

            // Initial or error state
            if (state is ProfileError) {
              return Center(
                child: Text(state.message),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
