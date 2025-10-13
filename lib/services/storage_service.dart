import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/user.dart';

class StorageService {
  static const String _usersKey = "users";
  static const String _currentUserKey = "currentUser";

  /// ==================== USER MANAGEMENT ====================

  static Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];

    final data = jsonDecode(jsonString) as List;
    return data
        .map((u) => AppUser(
              username: u["username"],
              email: u["email"],
              password: u["password"],
            ))
        .toList();
  }

  static Future<void> updateUser(AppUser oldUser, AppUser newUser) async {
  final users = await loadUsers();
  final index = users.indexWhere((u) => u.username == oldUser.username);
  if (index != -1) {
    users[index] = newUser;
    await saveUsers(users);
  }
  }

  static Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = users
        .map((u) => {
              "username": u.username,
              "email": u.email,
              "password": u.password,
            })
        .toList();
    await prefs.setString(_usersKey, jsonEncode(jsonData));
  }

  static Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode({
      "username": user.username,
      "email": user.email,
      "password": user.password,
    }));
  }

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentUserKey);
    if (jsonString == null) return null;

    final data = jsonDecode(jsonString);
    return AppUser(
      username: data["username"],
      email: data["email"],
      password: data["password"],
    );
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<void> deleteUserData(String username) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('expenses_$username');
  await prefs.remove('categories_$username');
  // Jika kamu menyimpan setting lain per user, tambahkan di sini juga.
  }

  /// ==================== EXPENSE ====================

  static Future<void> saveExpenses(String username, List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "expenses_$username";

    final jsonData = expenses.map((e) => {
          "id": e.id,
          "title": e.title,
          "amount": e.amount,
          "category": e.category,
          "date": e.date.toIso8601String(),
          "description": e.description,
        }).toList();
    await prefs.setString(key, jsonEncode(jsonData));
  }

  static Future<List<Expense>> loadExpenses(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "expenses_$username";
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final data = jsonDecode(jsonString) as List;
    return data
        .map((e) => Expense(
              id: e["id"],
              title: e["title"],
              amount: (e["amount"] as num).toDouble(),
              category: e["category"],
              date: DateTime.parse(e["date"]),
              description: e["description"],
            ))
        .toList();
  }

  /// ==================== CATEGORY ====================

  static Future<void> ensureDefaultCategories(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "categories_$username";

    final existing = prefs.getString(key);
    if (existing != null) return; // sudah ada, tidak perlu tambah default

    final defaultCategories = [
      Category(id: "1", name: "Makanan"),
      Category(id: "2", name: "Transportasi"),
      Category(id: "3", name: "Tabungan"),
      Category(id: "4", name: "Biaya Pendidikan"),
    ];

    await saveCategories(username, defaultCategories);
  }

  static Future<void> saveCategories(String username, List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "categories_$username";
    final jsonData =
        categories.map((c) => {"id": c.id, "name": c.name}).toList();
    await prefs.setString(key, jsonEncode(jsonData));
  }

  static Future<List<Category>> loadCategories(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "categories_$username";
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final data = jsonDecode(jsonString) as List;
    return data.map((c) => Category(id: c["id"], name: c["name"])).toList();
  }
}
