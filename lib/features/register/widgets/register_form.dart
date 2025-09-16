import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';

class RegisterForm extends StatefulWidget {
  final void Function(String name, String email, String password) onSubmit;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Name"),
            validator: (value) => Validators.name(value, 'Name'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (value) => Validators.email(value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) => Validators.password(value, 5),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordCtrl,
            decoration: const InputDecoration(labelText: "Confirm Password"),
            obscureText: true,
            validator: (value) =>
                Validators.confirmPassword(value, _passwordCtrl.text),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Register"),
            ),
          ),
        ],
      ),
    );
  }
}
