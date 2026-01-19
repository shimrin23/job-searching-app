import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import 'profile_event.dart';
import 'profile_event.dart';
import 'profile_state.dart';

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final StorageRepository storageRepository;

  ProfileBloc({required this.authRepository, required this.storageRepository})
    : super(ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadResume>(_onUploadResume);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(
        state.copyWith(status: ProfileStatus.error, message: failure.message),
      ),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await authRepository.updateProfile(
      name: event.user.name,
      phone: event.user.phone,
      location: event.user.location,
      skills: event.user.skills,
      profileImageUrl: event.user.profileImageUrl,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: ProfileStatus.error, message: failure.message),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.updated,
          user: user,
          message: 'Profile updated successfully',
        ),
      ),
    );
  }

  Future<void> _onUploadResume(
    UploadResume event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.uploading));

    final file = File(event.filePath);
    final uploadResult = await storageRepository.uploadResume(
      file,
      state.user!.id,
    );

    await uploadResult.fold(
      (failure) async {
        emit(
          state.copyWith(status: ProfileStatus.error, message: failure.message),
        );
      },
      (resumeUrl) async {
        final updateResult = await authRepository.updateProfile(
          name: state.user!.name,
        );
        // Note: Resume URL update needs to be handled in your backend

        updateResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ProfileStatus.error,
              message: failure.message,
            ),
          ),
          (user) => emit(
            state.copyWith(
              status: ProfileStatus.loaded,
              user: user.copyWith(resumeUrl: resumeUrl),
              message: 'Resume uploaded successfully',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.uploading));

    final file = File(event.filePath);
    final uploadResult = await storageRepository.uploadProfileImage(
      file,
      state.user!.id,
    );

    await uploadResult.fold(
      (failure) async {
        emit(
          state.copyWith(status: ProfileStatus.error, message: failure.message),
        );
      },
      (imageUrl) async {
        final updateResult = await authRepository.updateProfile(
          name: state.user!.name,
        );
        // Note: Profile image URL update needs to be handled in your backend

        updateResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ProfileStatus.error,
              message: failure.message,
            ),
          ),
          (user) => emit(
            state.copyWith(
              status: ProfileStatus.loaded,
              user: user.copyWith(profileImageUrl: imageUrl),
              message: 'Profile image uploaded successfully',
            ),
          ),
        );
      },
    );
  }
}
