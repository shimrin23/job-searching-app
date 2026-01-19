import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updated,
  uploading,
  uploaded,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? message;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.message,
  });

  ProfileState copyWith({ProfileStatus? status, User? user, String? message}) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
