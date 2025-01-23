import 'package:pd/services/auth/auth_provider.dart';
import 'package:pd/services/auth/auth_user.dart';
import 'package:pd/services/local_database.dart';
import 'package:pd/services/auth/auth_exceptions.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService implements AuthProvider {
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  AuthUser? _cachedUser;

  Future<LocalDatabase> get _db async => LocalDatabase.instance;

  AuthUser _mapRow(Map<String, dynamic> row) => AuthUser(
        id: row['id'].toString(),
        displayName: row['displayName'] as String,
        email: row['email'] as String,
        isEmailVerified: (row['isEmailVerified'] as int) == 1,
      );

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _cachedUser;
  }

  @override
  Future<void> initialize() async {
    final localDb = await _db;
    await localDb.database;
    // Optionally, load the user from the database if stored
  }

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final database = await (await _db).database;

    // Check if email already exists
    final existingUsers = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUsers.isNotEmpty) {
      throw EmailAlreadyInUseAuthException();
    }

    // Check if display name already exists
    final existingDisplayNames = await database.query(
      'users',
      where: 'displayName = ?',
      whereArgs: [displayName],
    );

    if (existingDisplayNames.isNotEmpty) {
      throw DisplayNameAlreadyInUseAuthException();
    }

    // Check password strength (simple example)
    if (password.length < 6) {
      throw WeakPasswordAuthException();
    }

    // Hash the password before storing
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    // Insert new user
    final id = await database.insert('users', {
      'displayName': displayName,
      'email': email,
      'password': hashedPassword, // Store hashed password
      'isEmailVerified': 0, // Initially not verified
    });

    _cachedUser = AuthUser(
      id: id.toString(),
      displayName: displayName,
      email: email,
      isEmailVerified: false,
    );

    // Optionally, send a verification email here
  }

  @override
  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    final database = await (await _db).database;
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (rows.isEmpty) {
      throw EmailAlreadyInUseAuthException(); // Consider creating a specific exception for user not found
    }

    final row = rows.first;
    final storedHashedPassword = row['password'] as String;

    // Verify the input password against the stored hashed password
    final isPasswordCorrect = BCrypt.checkpw(password, storedHashedPassword);

    if (!isPasswordCorrect) {
      throw InvalidEmailAuthException(); // Consider creating a specific exception for invalid password
    }

    final user = _mapRow(row);
    _cachedUser = user;
  }

  @override
  Future<void> logOut() async {
    _cachedUser = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_cachedUser == null) throw GenericAuthException();

    // Implement email verification logic here
    // For example, send an email with a verification link
    // Upon verification, update 'isEmailVerified' in the database
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    final database = await (await _db).database;
    final users = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [toEmail],
    );

    if (users.isEmpty) {
      throw EmailAlreadyInUseAuthException(); // Consider creating a specific exception for user not found
    }

    // Implement password reset logic here
    // For example, send a password reset link to the user's email
  }
}
