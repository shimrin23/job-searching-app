import 'package:equatable/equatable.dart';

// Base Failure Class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Network Failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid email or password',
  ]);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([
    super.message = 'Email is already registered',
  ]);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

// Data Failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse data']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

class FileUploadFailure extends StorageFailure {
  const FileUploadFailure([super.message = 'Failed to upload file']);
}

// Generic Failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
