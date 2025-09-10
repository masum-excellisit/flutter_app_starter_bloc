import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
        TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.read<LoginBloc>().add(LoginSubmitted(
              _userCtrl.text.trim(),
              _passCtrl.text.trim(),
            ));
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
