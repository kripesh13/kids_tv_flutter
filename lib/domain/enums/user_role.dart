import 'package:hive/hive.dart';

part 'user_role.g.dart';

@HiveType(typeId: 11)
enum UserRole {
  @HiveField(0)
  admin('admin', 'Admin'),

  @HiveField(1)
  user('user', 'User');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  // Aliases for clean migration
  static const UserRole superAdmin = UserRole.admin;
  static const UserRole editor = UserRole.admin;
  static const UserRole viewer = UserRole.user;

  static UserRole fromString(String? val) {
    if (val == null) return UserRole.user;
    final lower = val.toLowerCase();
    if (lower.contains('admin') || lower == 'editor') return UserRole.admin;
    return UserRole.user;
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isUser => this == UserRole.user;
  bool get canManageUsers => isAdmin;
  bool get canDeleteContent => isAdmin;
  bool get canEditContent => isAdmin;
  bool get canManageCategories => isAdmin;
  bool get canDeleteCategories => isAdmin;
  bool get isAdminPortalUser => isAdmin;
}
