import 'package:flutter/material.dart';

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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: "Password"),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () {
                    widget.onSubmit(
                      _nameCtrl.text,
                      _emailCtrl.text,
                      _passwordCtrl.text,
                    );
                  },
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
    );
  }
}
