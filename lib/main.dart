import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/auth/auth_service.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/auth/bloc/auth_state.dart';
import 'package:pd/views/builds/build_view.dart';
import 'package:pd/views/login_view.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/register_view.dart';
import 'package:pd/views/verify_email_view.dart';
import 'package:pd/views/builds/garage_view.dart';
import 'package:pd/views/builds/create_update_build_view.dart';
import 'package:pd/services/local_database.dart';
import 'package:pd/helpers/loading/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDatabase.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passion Driven',
      theme: ThemeData.dark().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (_) =>
            AuthBloc(AuthService.instance)..add(const AuthEventInitialize()),
        child: const AppNavigator(),
      ),
      routes: {
        '/garage': (context) => const GarageView(),
        '/create-build': (context) => const CreateUpdateBuildView(),
        '/build-view': (context) => const BuildDetailView(),
      },
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomeView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
