import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final User user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class UploadProfileImage extends ProfileEvent {
  final String filePath;

  const UploadProfileImage(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UploadResume extends ProfileEvent {
  final String filePath;

  const UploadResume(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
