// Simple auth repository that persists user into Hive via HiveLocalService
import 'package:uuid/uuid.dart';
import 'package:mini_news_intelligence/src/data/datasources/local/hive_local_service.dart';
import 'package:mini_news_intelligence/src/data/models/user_model.dart';

class AuthRepositoryImpl {
  final HiveLocalService localService;
  AuthRepositoryImpl({required this.localService});

  Future<UserModel> login(String username, String password, {bool remember = true}) async {
    // Simple validation and simulated delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Invalid credentials');
    }
    final user = UserModel(id: const Uuid().v4(), username: username, token: const Uuid().v4(), loggedInAt: DateTime.now().toUtc());
    await localService.persistAuth(user);
    return user;
  }

  Future<void> logout() async {
    await localService.clearAuth();
  }

  UserModel? getPersistedUser() {
    final box = localService.authBox;
    final user = box.get('user');
    return user;
  }
}
