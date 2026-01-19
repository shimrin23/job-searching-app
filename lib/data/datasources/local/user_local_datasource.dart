import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  Box<UserModel>? _userBox;

  Future<Box<UserModel>> get userBox async {
    if (_userBox == null || !_userBox!.isOpen) {
      _userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
    }
    return _userBox!;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final box = await userBox;
      await box.put('current_user', user);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final box = await userBox;
      return box.get('current_user');
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await userBox;
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
