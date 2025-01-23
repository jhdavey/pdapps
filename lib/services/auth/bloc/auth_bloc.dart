import 'package:bloc/bloc.dart';
import 'package:pd/services/auth/auth_provider.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;

  AuthBloc(this.provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // Handle register navigation
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    // Handle register
    on<AuthEventRegister>((event, emit) async {
      final displayName = event.displayName;
      final email = event.email;
      final password = event.password;

      emit(const AuthStateRegistering(
        exception: null,
        isLoading: true,
      ));

      try {
        await provider.register(
          displayName: displayName,
          email: email,
          password: password,
        );

        // Automatically log in after registration
        await provider.logIn(email: email, password: password);
        final user = await provider.getCurrentUser();

        emit(AuthStateLoggedIn(user: user!, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    // Initialize
    on<AuthEventInitialize>((event, emit) async {
      emit(const AuthStateUninitialized(isLoading: true));

      try {
        await provider.initialize();
        final user = await provider.getCurrentUser();

        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } catch (e) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }
    });

    on<AuthEventShouldLogIn>((event, emit) {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: false,
      ));
    });

    // Log in navigation
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Logging in...',
      ));

      try {
        await provider.logIn(
          email: event.email,
          password: event.password,
        );

        final user = await provider.getCurrentUser();

        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // Log out
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Logging out...',
      ));

      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // Forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));

      final email = event.email;
      if (email == null) {
        return; // User just wants to go to the forgot-password screen
      }

      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      try {
        await provider.sendPasswordReset(toEmail: email);
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: true,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateForgotPassword(
          exception: e,
          hasSentEmail: false,
          isLoading: false,
        ));
      }
    });
  }
}
