// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_provider.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/auth/bloc/auth_state.dart';
import 'package:pd/views/auth/verify_email_view.dart';
import 'package:pd/views/builds/build_note_editor_view.dart';
import 'package:pd/views/builds/create_build_view.dart';
import 'package:pd/views/builds/edit_build_view.dart';
import 'package:pd/views/auth/login_view.dart';
import 'package:pd/views/edit_profile_view.dart';
import 'package:pd/views/builds/build_view.dart';
import 'package:pd/views/auth/register_view.dart';
import 'package:pd/views/search_results_view.dart';
import 'package:pd/views/tag_view.dart';
import 'package:pd/views/categories_view.dart';
import 'package:pd/widgets/user_list.dart';
import 'package:pd/helpers/loading/loading_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pd/views/main_scaffold.dart';

import 'views/garage_view.dart';

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
              color: Color(0xFF0F141D),
            ),
            dialogTheme: const DialogTheme(
              backgroundColor: Color(0xFF0F141D),
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
            '/register': (context) => RegisterView(),
            '/login': (context) => LoginView(),

            // Tapping /home or initial logged‐in state → show the bottom‐tab scaffold itself
            '/home': (context) => const MainScaffold(),
            '/feedback': (context) => const MainScaffold(),

            // Whenever we push '/build-view', wrap BuildView in the same MainScaffold.
            '/build-view': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('id')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid build ID')),
                );
              }
              // We still pass the arguments into BuildView via routeArgumentsHelper internally.
              return const MainScaffold(
                overrideChild: BuildView(),
              );
            },

            '/garage': (ctx) {
              // Pull the userId out of the route arguments:
              final int userId = ModalRoute.of(ctx)!.settings.arguments as int;

              // Wrap that user’s GarageView in MainScaffold.overrideChild:
              return MainScaffold(
                overrideChild: GarageView(userId: userId),
              );
            },

            '/edit-profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('id')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid profile data')),
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
                  body: Center(child: Text('Invalid build data')),
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

            '/manage-note': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null || !args.containsKey('buildId')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid note data')),
                );
              }
              return ManageNotePage(
                buildId: args['buildId'],
                note: args['note'],
                reloadBuildData: args['reloadBuildData'] ?? () {},
              );
            },

            '/user-list': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              if (args == null ||
                  !args.containsKey('users') ||
                  !args.containsKey('title')) {
                return const Scaffold(
                  body: Center(child: Text('Invalid user list data')),
                );
              }
              return UserListView(
                users: args['users'],
                title: args['title'],
              );
            },

            '/verify-email': (context) => const VerifyEmailView(),
          },
        ),
      ),
    );
  }
}

/// Chooses between login/registration and the MainScaffold itself.
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
          // Once logged in, show MainScaffold (which by default lands on Home tab).
          return const MainScaffold();
        } else if (state is AuthStateRegistering) {
          return RegisterView();
        } else {
          return LoginView();
        }
      },
    );
  }
}
