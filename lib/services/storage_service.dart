import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';

class StorageService {
  static const String _expenseKey = "expenses";
  static const String _categoryKey = "categories";

  // ================== EXPENSE ==================
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = expenses.map((e) => {
      "id": e.id,
      "title": e.title,
      "amount": e.amount,
      "category": e.category,
      "date": e.date.toIso8601String(),
      "description": e.description,
    }).toList();
    await prefs.setString(_expenseKey, jsonEncode(jsonData));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expenseKey);
    if (jsonString == null) return [];

    final data = jsonDecode(jsonString) as List;
    return data.map((e) => Expense(
      id: e["id"],
      title: e["title"],
      amount: (e["amount"] as num).toDouble(),
      category: e["category"],
      date: DateTime.parse(e["date"]),
      description: e["description"],
    )).toList();
  }

  // ================== CATEGORY ==================
  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = categories.map((c) => {
      "id": c.id,
      "name": c.name,
    }).toList();
    await prefs.setString(_categoryKey, jsonEncode(jsonData));
  }

  static Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoryKey);
    if (jsonString == null) return [];

    final data = jsonDecode(jsonString) as List;
    return data.map((c) => Category(
      id: c["id"],
      name: c["name"],
    )).toList();
  }
}
