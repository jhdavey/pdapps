import 'package:bloc/bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiAuthService authService;

  AuthBloc(this.authService)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    on<AuthEventRegister>((event, emit) async {
      final displayName = event.displayName;
      final email = event.email;
      final password = event.password;

      emit(AuthStateRegistering(
        exception: null,
        isLoading: true,
      ));

      try {
        await authService.register(
          displayName: displayName,
          email: email,
          password: password,
        );

        await authService.logIn(email: email, password: password);
        final user = await authService.getCurrentUser();

        if (user != null && !user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user!, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) async {
      try {
        final user = await authService.getCurrentUser();
        if (user == null) throw Exception("User not found");
        await authService.sendEmailVerification();
      } catch (e) {
        // Handle error
      }
    });

    // Initialize
    on<AuthEventInitialize>((event, emit) async {
      emit(const AuthStateUninitialized(isLoading: true));

      try {
        await authService.initialize();
        final user = await authService.getCurrentUser();

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

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Logging in...',
      ));

      try {
        await authService.logIn(
          email: event.email,
          password: event.password,
        );

        final user = await authService.getCurrentUser();

        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else {
          if (!user.isEmailVerified) {
            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Logging out...',
      ));

      try {
        await authService.logOut();
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
        return;
      }

      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      try {
        await authService.sendPasswordReset(toEmail: email);
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
