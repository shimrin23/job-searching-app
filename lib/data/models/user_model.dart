import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? profileImageUrl;

  @HiveField(5)
  final String? resumeUrl;

  @HiveField(6)
  final List<String> skills;

  @HiveField(7)
  final String? location;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.profileImageUrl,
    this.resumeUrl,
    this.skills = const [],
    this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as DateTime),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'])
                : (json['updatedAt'] as DateTime))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'resumeUrl': resumeUrl,
      'skills': skills,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      profileImageUrl: user.profileImageUrl,
      resumeUrl: user.resumeUrl,
      skills: user.skills,
      location: user.location,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      profileImageUrl: profileImageUrl,
      resumeUrl: resumeUrl,
      skills: skills,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
