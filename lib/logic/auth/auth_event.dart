import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignOutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthStateChangeRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? location;
  final List<String>? skills;

  const UpdateProfileRequested({
    this.name,
    this.phone,
    this.location,
    this.skills,
  });

  @override
  List<Object?> get props => [name, phone, location, skills];
}
