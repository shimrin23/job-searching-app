import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final String fileName = 'profile_$userId${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('profile_images/$fileName');

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload resume/CV
  Future<String> uploadResume(File file, String userId) async {
    try {
      final String fileName = 'resume_$userId${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('resumes/$fileName');

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: path.extension(file.path) == '.pdf'
              ? 'application/pdf'
              : 'application/octet-stream',
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload resume: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
