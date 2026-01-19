import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../core/error/failures.dart';

abstract class StorageRepository {
  Future<Either<Failure, String>> uploadResume(File file, String userId);

  Future<Either<Failure, String>> uploadProfileImage(File file, String userId);

  Future<Either<Failure, void>> deleteFile(String fileUrl);
}
