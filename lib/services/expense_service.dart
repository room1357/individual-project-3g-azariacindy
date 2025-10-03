import '../models/expense.dart';
import 'storage_service.dart';

class ExpenseService {

  static List<Expense> expenses = [];

  /// Load data dari file JSON
  static Future<void> loadData() async {
    expenses = await StorageService.loadExpenses();
  }

  /// Tambah expense baru
  static Future<void> addExpense(Expense expense) async {
    expenses.add(expense);
    await StorageService.saveExpenses(expenses);
  }

  /// Update expense (edit)
  static Future<void> updateExpense(Expense updatedExpense) async {
    int index = expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      expenses[index] = updatedExpense;
      await StorageService.saveExpenses(expenses);
    }
  }

  /// Hapus expense
  static Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    await StorageService.saveExpenses(expenses);
  }
}
