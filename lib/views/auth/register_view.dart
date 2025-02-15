import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_exception.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/auth/bloc/auth_state.dart';
import 'package:pd/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _displayName;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _displayName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering && state.exception != null) {
          if (state.exception is WeakPasswordException) {
            if (!mounted) return;
            await showErrorDialog(context, 'Weak password');
          } else if (state.exception is InvalidCredentialsException) {
            if (!mounted) return;
            await showErrorDialog(context, 'Display name is unavailable');
          } else if (state.exception is EmailAlreadyInUseException) {
            if (!mounted) return;
            await showErrorDialog(context, 'Email is unavailable');
          } else if (state.exception is InvalidEmailException) {
            if (!mounted) return;
            await showErrorDialog(context, 'Invalid email');
          } else if (state.exception is GenericApiException) {
            if (!mounted) return;
            await showErrorDialog(context, 'Failed to register');
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                  'Register',
                  style: TextStyle(fontSize: 24),
                ),
                  TextField(
                    controller: _displayName,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your display name here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email here',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password here',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final displayName = _displayName.text.trim();
                      final email = _email.text.trim();
                      final password = _password.text.trim();
          
                      // Basic validation
                      if (displayName.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty) {
                        if (!mounted) return;
                        await showErrorDialog(
                            context, 'Please fill in all fields.');
                        return;
                      }
          
                      context.read<AuthBloc>().add(
                            AuthEventRegister(
                              displayName,
                              email,
                              password,
                            ),
                          );
                    },
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventShouldLogIn(),
                          );
                    },
                    child: const Text('Already registered? Login here!'),
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
