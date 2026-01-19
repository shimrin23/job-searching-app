import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, User>> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? phone,
    String? location,
    List<String>? skills,
    String? profileImageUrl,
  });
}
