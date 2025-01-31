import 'package:pd/services/api/auth_exception.dart';
import 'package:pd/services/api/auth_provider.dart';
import 'package:pd/services/api/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Auth', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User shoud be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be initialized in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delgate to login function', () async {
      final badCredUser = provider.createUser(
        displayName: 'tester',
        email: 'foo@bar.com',
        password: 'foobar',
      );
      expect(badCredUser,
          throwsA(const TypeMatcher<InvalidCredentialsException>()));

      final user = await provider.createUser(
        displayName: 'tester',
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements ApiAuthProvider {
  AuthUser? _user;

  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<AuthUser> createUser({
    required String displayName,
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw InvalidCredentialsException();
    if (password == 'foobar') throw InvalidCredentialsException();
    const user = AuthUser(
        id: '1',
        isEmailVerified: false,
        email: 'foo@bar.com',
        displayName: 'tester');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw InvalidCredentialsException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw InvalidCredentialsException();
    const newUser = AuthUser(
      id: '1',
      isEmailVerified: true,
      email: 'foo@bar.com',
      displayName: 'tester',
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    // add test logic
    throw UnimplementedError();
  }
  
  @override
  Future<AuthUser?> getCurrentUser() => throw UnimplementedError();
  
  @override
  Future<void> register({required String displayName, required String email, required String password}) => throw UnimplementedError();
  
  @override
  // TODO: implement baseUrl
  String get baseUrl => throw UnimplementedError();
}
