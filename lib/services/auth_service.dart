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

    static Future<bool> deleteAccount(String username) async {
    final users = await StorageService.loadUsers();

    // Cari dan hapus user
    users.removeWhere((u) => u.username == username);
    await StorageService.saveUsers(users);

    // Hapus data lain milik user
    await StorageService.deleteUserData(username);

    // Logout otomatis
    await StorageService.clearCurrentUser();

    return true;
  }

  static Future<void> logout() => StorageService.clearCurrentUser();
}
