import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static Future<bool> register(String username, String email, String password) async {
    final users = await StorageService.loadUsers();

    // Cegah username/email duplikat
    if (users.any((u) => u.username == username || u.email == email)) {
      return false;
    }

    users.add(AppUser(username: username, email: email, password: password));
    await StorageService.saveUsers(users);
    return true;
  }

  static Future<AppUser?> login(String identifier, String password) async {
    final users = await StorageService.loadUsers();
    try {
      final user = users.firstWhere((u) =>
          (u.username == identifier || u.email == identifier) &&
          u.password == password);
      await StorageService.saveCurrentUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() => StorageService.clearCurrentUser();
}
