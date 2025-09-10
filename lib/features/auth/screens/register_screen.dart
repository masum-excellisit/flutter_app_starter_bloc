import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirm() {
    setState(() => _obscureConfirm = !_obscureConfirm);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    if (value.trim().length < 2) return 'Name too short';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value.trim())) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulate a network request or hook into your bloc/repository here.
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful (demo)')),
    );

    // Optionally navigate or clear form
    // Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.secondary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Join us! Fill the form to create an account.',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar placeholder
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.person,
                                      size: 30, color: Colors.white),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Material(
                                    elevation: 2,
                                    shape: const CircleBorder(),
                                    color: theme.colorScheme.primary,
                                    child: IconButton(
                                      iconSize: 18,
                                      padding: const EdgeInsets.all(4),
                                      onPressed: () {
                                        // Add image picker or avatar edit integration here.
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Pick avatar (not implemented)')),
                                        );
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                textInputAction: TextInputAction.next,
                                validator: _validateName,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: 'Full Name',
                                  hintText: 'John Doe',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: 'Email',
                                  hintText: 'you@example.com',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: _togglePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                textInputAction: TextInputAction.done,
                                validator: _validateConfirm,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: 'Confirm Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: _toggleConfirm,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Text('Create Account',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                          Divider(color: Colors.grey.shade300)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('or',
                                        style:
                                            TextStyle(color: Colors.black54)),
                                  ),
                                  Expanded(
                                      child:
                                          Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialButton(
                                    asset: Icons.facebook,
                                    label: 'Facebook',
                                    color: const Color(0xFF1877F2),
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Continue with Facebook (demo)')),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _SocialButton(
                                    asset: Icons.g_mobiledata,
                                    label: 'Google',
                                    color: const Color(0xFFDB4437),
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Continue with Google (demo)')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  context.goNamed('login');
                                },
                                child: const Text(
                                    'Already have an account? Sign in'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData asset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    Key? key,
    required this.asset,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(asset, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
