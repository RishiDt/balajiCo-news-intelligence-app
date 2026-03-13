// Auth providers using Riverpod and a simple AuthNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/data/models/user_model.dart';
import 'package:mini_news_intelligence/src/features/auth/auth_repository_impl.dart';
import 'package:mini_news_intelligence/src/data/datasources/local/hive_local_service.dart';

final hiveLocalServiceProvider = Provider<HiveLocalService>((ref) {
  return HiveLocalService();
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final local = ref.read(hiveLocalServiceProvider);
  return AuthRepositoryImpl(localService: local);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({bool? isLoading, bool? isAuthenticated, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl repository;

  AuthNotifier(this.repository) : super(AuthState());

  Future<void> checkAuthOnStartup() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = repository.getPersistedUser();
      if (user != null) {
        state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
      } else {
        state = state.copyWith(isAuthenticated: false, user: null, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String username, String password, {bool remember = true}) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(error: 'Username and password required');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.login(username.trim(), password.trim(), remember: remember);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await repository.logout();
      state = state.copyWith(isAuthenticated: false, user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final notifier = AuthNotifier(repo);
  notifier.checkAuthOnStartup();
  return notifier;
});
