import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_data_source.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/enums/user_role.dart';

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  return ApiDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return AuthRepository(ds);
});

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isUser => user?.role == UserRole.user;
  bool get canManageCategories => isAdmin;

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    try {
      final user = await _repo.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repo.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password, {
    String? displayName,
    int? age,
    String? pinCode,
    UserRole initialRole = UserRole.user,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
        age: age,
        pinCode: pinCode,
        initialRole: initialRole,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> signInWithDemo({UserRole role = UserRole.admin}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repo.signInWithDemo(role: role);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = const AuthState();
  }

  Future<List<UserProfile>> getAllProfiles() async {
    return _repo.getAllProfiles();
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    await _repo.updateUserRole(userId, role);
    if (state.user?.id == userId) {
      state = state.copyWith(user: state.user?.copyWith(role: role));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
