// Custom Exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class ParsingException implements Exception {
  final String message;

  ParsingException([this.message = 'Failed to parse data']);

  @override
  String toString() => 'ParsingException: $message';
}

class StorageException implements Exception {
  final String message;

  StorageException([this.message = 'Storage error']);

  @override
  String toString() => 'StorageException: $message';
}
