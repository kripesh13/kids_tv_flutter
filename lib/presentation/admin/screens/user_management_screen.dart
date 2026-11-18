import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../domain/enums/user_role.dart';
import '../../providers/auth_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<UserProfile> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await ref.read(authProvider.notifier).getAllProfiles();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _changeRole(UserProfile user, UserRole newRole) async {
    await ref.read(authProvider.notifier).updateUserRole(user.id, newRole);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${user.email} to ${newRole.label}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Role-Based Access Control', style: AppTypography.headlineLarge),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.purple.withAlpha(60)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security_rounded, color: AppColors.purple, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Super Admin Area: Manage platform access rights. Changes are synchronized with Kids TV backend server.',
                            style: TextStyle(color: AppColors.purple, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.displayName ?? user.email,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Email: ${user.email} • ID: ${user.id}'),
                            trailing: DropdownButton<UserRole>(
                              value: user.role,
                              underline: const SizedBox(),
                              items: UserRole.values.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: role == UserRole.superAdmin
                                          ? AppColors.purple
                                          : (role == UserRole.admin
                                              ? AppColors.primary
                                              : (role == UserRole.editor
                                                  ? AppColors.accent
                                                  : AppColors.textSecondary)),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newRole) {
                                if (newRole != null && newRole != user.role) {
                                  _changeRole(user, newRole);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
