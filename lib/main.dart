import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/constants/routes.dart';
import 'package:pd/helpers/loading/loading_screen.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/auth/bloc/auth_state.dart';
import 'package:pd/services/auth/firebase_auth_provider.dart';
import 'package:pd/views/forgot_password_view.dart';
import 'package:pd/views/login_view.dart';
import 'package:pd/views/builds/create_update_note_view.dart';
import 'package:pd/views/builds/home_view.dart';
import 'package:pd/views/register_view.dart';
import 'package:pd/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 17, 23, 28),
      appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(255, 17, 23, 28),
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        displayLarge: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white, fontSize: 16),
        titleSmall: TextStyle(color: Colors.white, fontSize: 14),
        bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
        labelSmall: TextStyle(color: Colors.grey, fontSize: 10),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white), // Bottom line color
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white, width: 2), // Bottom line on focus
        ),
        hintStyle: TextStyle(color: Colors.white54), // Hint text color
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white, // Caret color
      ),
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateBuildRoute: (context) => const CreateUpdateBuildView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomeView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
