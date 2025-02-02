// main.dart
// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_provider.dart';
import 'package:pd/services/api/auth_service.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/auth/bloc/auth_state.dart';
import 'package:pd/views/builds/create_build_view.dart';
import 'package:pd/views/builds/edit_build_view.dart';
import 'package:pd/views/auth/login_view.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/garage_view.dart';
import 'package:pd/views/builds/build_view.dart';
import 'package:pd/views/auth/register_view.dart';
import 'package:pd/views/tag_view.dart';
import 'package:pd/views/categories_view.dart';
import 'package:pd/helpers/loading/loading_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiAuthProvider and ApiAuthService
  final apiAuthProvider = ApiAuthProvider(
    baseUrl: 'https://passiondrivenbuilds.com/api',
  );
  final apiAuthService = ApiAuthService(apiAuthProvider);

  await apiAuthService.initialize();

  runApp(MyApp(
    authService: apiAuthService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiAuthService authService;

  const MyApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ApiAuthService>(
      create: (_) => authService,
      child: BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(authService)..add(const AuthEventInitialize()),
        child: MaterialApp(
          navigatorObservers: [routeObserver],
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
          routes: {
            '/build-view': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('id')) {
                return const Scaffold(
                  body: Center(
                    child: Text('Invalid build ID'),
                  ),
                );
              }
              // You may retrieve the build ID if needed
              return const BuildView();
            },
            '/garage': (context) => const GarageView(),
            '/create-update-build': (context) => CreateBuildView(),
            '/edit-build-view': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('build')) {
                return const Scaffold(
                  body: Center(
                    child: Text('Invalid build data'),
                  ),
                );
              }
              final build = args['build'];
              return EditBuildView(build: build);
            },
            '/tag-view': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('tag')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid tag data')),
                );
              }
              final tag = args['tag'];
              return TagView(tag: tag);
            },
            '/categories-view': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('category')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid category data')),
                );
              }
              final category = args['category'] as String;
              return CategoriesView(category: category);
            },
          },
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
