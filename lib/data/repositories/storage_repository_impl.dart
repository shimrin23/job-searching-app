import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage storage;

  StorageRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, String>> uploadResume(File file, String userId) async {
    try {
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = storage.ref().child(AppConstants.resumesPath).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(FileUploadFailure(e.message ?? 'Failed to upload resume'));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    File file,
    String userId,
  ) async {
    try {
      final fileName = '${userId}${path.extension(file.path)}';
      final ref = storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(
        FileUploadFailure(e.message ?? 'Failed to upload profile image'),
      );
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String fileUrl) async {
    try {
      final ref = storage.refFromURL(fileUrl);
      await ref.delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(StorageFailure(e.message ?? 'Failed to delete file'));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
