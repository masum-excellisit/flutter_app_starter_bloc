import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.register),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.lg),

                  Text(
                    'Create Account',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xs),

                  Text(
                    'Please fill in the details to create your account.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // First Name Field
                  AuthFormField(
                    controller: _firstNameController,
                    label: AppStrings.firstName,
                    hint: 'Enter your first name',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) =>
                        Validators.name(value, AppStrings.firstName),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Last Name Field
                  AuthFormField(
                    controller: _lastNameController,
                    label: AppStrings.lastName,
                    hint: 'Enter your last name',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) =>
                        Validators.name(value, AppStrings.lastName),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Username Field
                  AuthFormField(
                    controller: _usernameController,
                    label: AppStrings.username,
                    hint: 'Choose a username',
                    prefixIcon: const Icon(Icons.alternate_email),
                    validator: Validators.username,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Email Field
                  AuthFormField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Password Field
                  AuthFormField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Confirm Password Field
                  AuthFormField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hint: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Register Button
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      } else if (state is AuthAuthenticated) {
                        context.go('/home');
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.register,
                        onPressed:
                            state is AuthLoading ? null : _onRegisterPressed,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text(AppStrings.signIn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
