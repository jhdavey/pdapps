import 'package:pd/services/auth/auth_provider.dart';
import 'package:pd/services/auth/auth_user.dart';
import 'package:pd/services/local_database.dart';

class AuthService implements AuthProvider {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  AuthUser? _cachedUser;

  Future<LocalDatabase> get _db async => LocalDatabase.instance;

  AuthUser _mapRow(Map<String, dynamic> row) => AuthUser(
        id: row['id'] as int,
        displayName: row['displayName'] as String,
        email: row['email'] as String,
        isEmailVerified: (row['isEmailVerified'] as int) == 1,
      );

  @override
  AuthUser? get currentUser => _cachedUser;

  @override
  Future<void> initialize() async {
    final localDb = await _db;
    await localDb.database;
  }

  @override
  Future<AuthUser> createUser({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final database = await (await _db).database;
    final id = await database.insert('users', {
      'displayName': displayName,
      'email': email,
      'isEmailVerified': 1,
    });
    return AuthUser(
      id: id,
      displayName: displayName,
      email: email,
      isEmailVerified: true,
    );
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    final database = await (await _db).database;
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (rows.isEmpty) throw Exception('User not found');
    final user = _mapRow(rows.first);
    _cachedUser = user; 
    return user;
  }

  @override
  Future<void> logOut() async {
    _cachedUser = null;
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {}
}
