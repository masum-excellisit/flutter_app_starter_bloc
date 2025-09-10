import 'package:flutter/material.dart';
import 'package:flutter_app_starter_bloc/features/splash/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _tryLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging in...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLarge = mq.size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D0EB5), Color(0xFF4059F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 80 : 24,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500, // nice width for web/tablet
              ),
              child: Card(
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome back',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sign in to continue',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter email';
                                }
                                final emailRegex =
                                    RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(v)) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter password';
                                }
                                if (v.length < 6) {
                                  return 'Password too short';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Sign in button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _tryLogin,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('or continue with',
                                      style: TextStyle(color: Colors.black54)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Social buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                _SocialButton(
                                  label: 'Google',
                                  color: Colors.redAccent,
                                  icon: Icons.g_mobiledata,
                                  onPressed: _dummy,
                                ),
                                SizedBox(width: 12),
                                _SocialButton(
                                  label: 'Apple',
                                  color: Colors.black,
                                  icon: Icons.apple,
                                  onPressed: _dummy,
                                ),
                                SizedBox(width: 12),
                                _SocialButton(
                                  label: 'Facebook',
                                  color: Color(0xFF1877F2),
                                  icon: Icons.facebook,
                                  onPressed: _dummy,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                      // Sign up
                      Column(
                        //  mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              context.goNamed('register');
                            },
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
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

void _dummy() {}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label, style: const TextStyle(color: Colors.black87)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: Colors.black12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
