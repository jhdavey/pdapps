// main.dart
// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_provider.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/auth/bloc/auth_state.dart';
import 'package:pd/views/builds/build_note_view.dart';
import 'package:pd/views/builds/create_build_view.dart';
import 'package:pd/views/builds/edit_build_view.dart';
import 'package:pd/views/auth/login_view.dart';
import 'package:pd/views/edit_profile_view.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/garage_view.dart';
import 'package:pd/views/builds/build_view.dart';
import 'package:pd/views/auth/register_view.dart';
import 'package:pd/views/search_results_view.dart';
import 'package:pd/views/tag_view.dart';
import 'package:pd/views/categories_view.dart';
import 'package:pd/helpers/loading/loading_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          localizationsDelegates: const [
            quill.FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          theme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F141D),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F141D),
            cardTheme: const CardTheme(
              color: Color(0xFF1F242C),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF1F242C),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F242C),
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEFFFFF),
              ),
            ),
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
            '/login': (context) => const LoginView(),
            '/build-view': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('id')) {
                return const Scaffold(
                  body: Center(
                    child: Text('Invalid build ID'),
                  ),
                );
              }
              return const BuildView();
            },
            '/garage': (context) => const GarageView(),
            '/edit-profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('id')) {
                return const Scaffold(
                  body: Center(
                    child: Text('Invalid profile data'),
                  ),
                );
              }
              return EditProfileView(user: args);
            },
            '/create-update-build': (context) => CreateBuildView(),
            '/edit-build-view': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
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
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('tag')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid tag data')),
                );
              }
              final tag = args['tag'];
              return TagView(tag: tag);
            },
            '/categories-view': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('category')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid category data')),
                );
              }
              final category = args['category'] as String;
              return CategoriesView(category: category);
            },
            '/search-results': (context) {
              final query =
                  ModalRoute.of(context)!.settings.arguments as String;
              return SearchResultsView(query: query);
            },
            // New route for the manage note page.
            '/manage-note': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('buildId')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid note data')),
                );
              }
              // Since callbacks are non-serializable, we provide a fallback no-op callback.
              return ManageNotePage(
                buildId: args['buildId'],
                note: args['note'], // May be null if adding a new note.
                reloadBuildData: args['reloadBuildData'] ?? () {},
              );
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
