// Login exceptions
class InvalidCredentialsAuthException implements Exception {}

// Register exceptions
class WeakPasswordAuthException implements Exception {}

class DisplayNameAlreadyInUseAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// Generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
