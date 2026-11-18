import '../../domain/enums/user_role.dart';
import '../datasources/remote/api_data_source.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  final ApiDataSource _dataSource;
  AuthRepository(this._dataSource);

  Future<UserProfile?> getCurrentUser() => _dataSource.getCurrentUserProfile();

  Future<UserProfile> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  Future<UserProfile> signUp({
    required String email,
    required String password,
    String? displayName,
    int? age,
    String? pinCode,
    UserRole initialRole = UserRole.user,
  }) =>
      _dataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
        age: age,
        pinCode: pinCode,
        initialRole: initialRole,
      );

  Future<UserProfile> signInWithDemo({UserRole role = UserRole.admin}) =>
      _dataSource.signInWithDemo(role: role);

  Future<void> signOut() => _dataSource.signOut();

  Future<List<UserProfile>> getAllProfiles() => _dataSource.getAllProfiles();

  Future<void> updateUserRole(String userId, UserRole role) =>
      _dataSource.updateUserRole(userId, role);

  Future<void> resetPassword(String email) => _dataSource.resetPassword(email);
}
