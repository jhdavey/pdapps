// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/gestures.dart';
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
  bool _agreedToEULA = false;

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

  Future<void> _showEULADialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1F242C),
        insetPadding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  '''
End User License Agreement (EULA) for Passion Driven
Last Updated: Feb 13, 2025

By creating an account or using the Passion Driven app (“App”), you agree to be bound by this End User License Agreement (“EULA”) and our Privacy Policy. If you do not agree to these terms, do not register for or use the App.

User-Generated Content & Guidelines
You agree that any content you post will comply with our community guidelines.
Objectionable content—including hate speech, harassment, explicit or violent material—is strictly prohibited.

Content Moderation, Reporting, and Blocking
We monitor user-generated content and reserve the right to remove or modify content that violates these guidelines.

The App provides tools that allow you to hide or flag objectionable content, report inappropriate build cards and images, or user profiles, and block abusive users by selecting their profiles. Reports will be reviewed and acted upon within 24 hours.

Enforcement & Account Termination
Repeated or severe violations may result in the suspension or termination of your account.

User Agreement
By using the App and checking the box below, you acknowledge that you have read and agree to this EULA and our Privacy Policy.

Disclaimers & Limitation of Liability
The App is provided “as is” without warranties of any kind. We are not liable for any damages arising from user-generated content.

Governing Law
This EULA is governed by the laws of the state of Florida.
''',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRegisterButtonPressed() async {
    final displayName = _displayName.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
      await showErrorDialog(context, 'Please fill in all fields.');
      return;
    }

    context.read<AuthBloc>().add(
          AuthEventRegister(displayName, email, password),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering && state.exception != null) {
          final errorMessage = state.exception is ApiException
              ? (state.exception as ApiException).message
              : "An unknown error occurred. Please try again.";
          await showErrorDialog(context, errorMessage);
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreedToEULA,
                        onChanged: (value) {
                          setState(() {
                            _agreedToEULA = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "By checking this box I agree to the ",
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: "End User License Agreement",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showEULADialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _agreedToEULA ? _onRegisterButtonPressed : null,
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
