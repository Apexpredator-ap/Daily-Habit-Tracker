class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException: $message ($code)';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message ($code)';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
