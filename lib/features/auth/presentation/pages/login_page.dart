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

/// ✅ Wrapper that provides [AuthBloc] to the login view.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

/// ✅ Separated stateful widget so [BuildContext] has access to [AuthBloc].
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.xxl),

                    // Logo
                    const Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.md),

                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.xs),

                    Text(
                      'Welcome back! Please sign in to continue.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    // Username Field
                    AuthFormField(
                      controller: _usernameController,
                      label: AppStrings.username,
                      hint: 'Enter your username',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) =>
                          Validators.required(value, AppStrings.username),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Password Field
                    AuthFormField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      hint: 'Enter your password',
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
                    const SizedBox(height: AppSizes.sm),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text(AppStrings.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Login Button
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
                          context.go('/profile');
                        }
                      },
                      builder: (context, state) {
                        return CustomButton(
                          text: AppStrings.login,
                          onPressed:
                              state is AuthLoading ? null : _onLoginPressed,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Spacer pushes Register link to bottom
                    const Spacer(),

                    // Register Link
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(
                    //       AppStrings.dontHaveAccount,
                    //       style: AppTextStyles.bodyMedium.copyWith(
                    //         color: AppColors.textSecondary,
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {
                    //         context.push('/register');
                    //       },
                    //       child: const Text(AppStrings.signUp),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
