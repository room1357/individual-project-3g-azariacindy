import '../models/expense.dart';
import 'storage_service.dart';

class ExpenseService {
  static final Map<String, List<Expense>> _userExpenses = {};

  static Future<void> loadData(String username) async {
    final loaded = await StorageService.loadExpenses(username);
    _userExpenses[username] = loaded;
  }

  static List<Expense> getExpenses(String username) {
    return _userExpenses[username] ?? [];
  }

  static Future<void> addExpense(String username, Expense expense) async {
    final expenses = _userExpenses[username] ?? [];
    expenses.add(expense);
    _userExpenses[username] = expenses;
    await StorageService.saveExpenses(username, expenses);
  }

  static Future<void> updateExpense(String username, Expense updated) async {
    final expenses = _userExpenses[username] ?? [];
    final index = expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      expenses[index] = updated;
      await StorageService.saveExpenses(username, expenses);
    }
  }

  static Future<void> deleteExpense(String username, String id) async {
    final expenses = _userExpenses[username] ?? [];
    expenses.removeWhere((e) => e.id == id);
    await StorageService.saveExpenses(username, expenses);
  }
}
