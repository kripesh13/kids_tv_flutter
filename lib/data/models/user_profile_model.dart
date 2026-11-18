import 'package:hive/hive.dart';
import '../../domain/enums/user_role.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 6)
class UserProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final UserRole role;

  @HiveField(3)
  final String? displayName;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final int? age;

  @HiveField(8)
  final String? pinCode;

  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.age,
    this.pinCode,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      displayName: (json['name'] ?? json['display_name']) as String?,
      avatarUrl: json['avatar_url'] as String?,
      age: (json['age'] as num?)?.toInt(),
      pinCode: json['pin_code']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'display_name': displayName,
      'name': displayName,
      'avatar_url': avatarUrl,
      'age': age,
      'pin_code': pinCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? age,
    String? pinCode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      age: age ?? this.age,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}
