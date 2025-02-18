class ApiException implements Exception {
  final String message;
  final String code;

  ApiException({required this.message, required this.code});

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

// Specific Authentication Exceptions
class InvalidCredentialsException extends ApiException {
  InvalidCredentialsException()
      : super(message: 'Invalid credentials provided.', code: 'invalid_credentials');
}

class UserNotFoundException extends ApiException {
  UserNotFoundException()
      : super(message: 'The requested user was not found.', code: 'user_not_found');
}

class EmailAlreadyInUseException extends ApiException {
  EmailAlreadyInUseException()
      : super(message: 'The email is already in use.', code: 'email_already_in_use');
}

class WeakPasswordException extends ApiException {
  WeakPasswordException()
      : super(message: 'The provided password must be at least 8 characters long.', code: 'weak_password');
}

class InvalidEmailException extends ApiException {
  InvalidEmailException()
      : super(message: 'The provided email address is invalid.', code: 'invalid_email');
}

class UnauthenticatedException extends ApiException {
  UnauthenticatedException()
      : super(message: 'You must be logged in to perform this action.', code: 'unauthenticated');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super(message: 'You do not have permission to perform this action.', code: 'unauthorized');
}

class GenericApiException extends ApiException {
  GenericApiException()
      : super(message: 'An unknown error occurred. Please try again.', code: 'unknown_error');
}
