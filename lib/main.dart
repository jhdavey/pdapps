import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_provider.dart'; // API-specific AuthProvider
import 'package:pd/services/api/auth_service.dart'; // ApiAuthService
import 'package:pd/services/auth/auth_provider.dart'; // General AuthProvider
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/auth/bloc/auth_state.dart';
import 'package:pd/views/login_view.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/register_view.dart';
import 'package:pd/helpers/loading/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiAuthProvider with your API base URL
  final apiAuthProvider = ApiAuthProvider(
    baseUrl: 'https://passiondrivenbuilds.com/api',
  );

  // Initialize ApiAuthService with the ApiAuthProvider
  final apiAuthService = ApiAuthService(apiAuthProvider);

  runApp(MyApp(
    authService: apiAuthService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthProvider authService;

  const MyApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthProvider>(
      create: (_) => authService,
      child: BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(authService)..add(const AuthEventInitialize()),
        child: MaterialApp(
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
          home: const AppNavigator(),
        ),
      ),
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
        } else {
          return const LoginView();
        }
      },
    );
  }
}
