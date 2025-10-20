import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import 'storage_service.dart';

class ExpenseService {
  static final Map<String, List<Expense>> _allExpenses = {};

  // Muat data untuk username dan juga cari expense dari user lain
  static Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // init dari storage (pemilik dan juga shared ones akan ditambahkan)
    final own = await StorageService.loadExpenses(username);
    _allExpenses[username] = List<Expense>.from(own);

    // cek semua key yang berisi expenses_*
    for (var key in prefs.getKeys()) {
      if (key.startsWith("expenses_")) {
        final otherUser = key.replaceFirst('expenses_', '');
        if (otherUser == username) continue;

        final others = await StorageService.loadExpenses(otherUser);

        for (var e in others) {
          // jika expense ini dibagikan ke username, tambahkan (hindari duplikat)
          if (e.sharedWith.contains(username)) {
            final exists = _allExpenses[username]!
                .any((ex) => ex.id == e.id && ex.owner == e.owner);
            if (!exists) {
              _allExpenses[username]!.add(e);
            }
          }
        }
      }
    }
  }

  // Sinkronisasi shared expenses untuk semua user yang terlibat
  static Future<void> syncSharedExpenses(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Update untuk owner
    await loadData(expense.owner);
    
    // Update untuk semua user yang di-share
    for (var username in expense.sharedWith) {
      await loadData(username);
    }
  }

  // Sinkron, kembalikan cache (jika perlu async, gunakan getExpensesAsync)
  static List<Expense> getExpenses(String username) {
    return _allExpenses[username] ?? [];
  }

  // Async helper untuk memastikan load dulu
  static Future<List<Expense>> getExpensesAsync(String username) async {
    if (!_allExpenses.containsKey(username)) {
      await loadData(username);
    }
    return _allExpenses[username] ?? [];
  }

  static Future<void> addExpense(String username, Expense expense) async {
    final userExpenses = _allExpenses[username] ?? [];
    userExpenses.add(expense);
    _allExpenses[username] = userExpenses;
    await StorageService.saveExpenses(username, userExpenses);
    
    // Sinkronisasi shared expenses
    await syncSharedExpenses(expense);
  }

  static Future<void> updateExpense(String username, Expense updatedExpense) async {
    final userExpenses = _allExpenses[username] ?? [];
    final index = userExpenses.indexWhere((e) => e.id == updatedExpense.id && e.owner == updatedExpense.owner);
    if (index != -1) {
      userExpenses[index] = updatedExpense;
      _allExpenses[username] = userExpenses;
      // Save only owner's list (if current username == owner, save to that user's storage)
      await StorageService.saveExpenses(updatedExpense.owner, 
          // get the owner's list from cache (or empty)
          _allExpenses[updatedExpense.owner] ?? []);
    } else {
      // jika tidak ditemukan di cache user, coba di owner's list
      final ownerExpenses = _allExpenses[updatedExpense.owner] ?? [];
      final ownerIndex = ownerExpenses.indexWhere((e) => e.id == updatedExpense.id);
      if (ownerIndex != -1) {
        ownerExpenses[ownerIndex] = updatedExpense;
        _allExpenses[updatedExpense.owner] = ownerExpenses;
        await StorageService.saveExpenses(updatedExpense.owner, ownerExpenses);
      }
    }
    
    // Sinkronisasi shared expenses
    await syncSharedExpenses(updatedExpense);
  }

  static Future<void> deleteExpense(String username, String id) async {
    // Hapus dari cache username (viewing user)
    final userExpenses = _allExpenses[username] ?? [];
    final toRemove = userExpenses.where((e) => e.id == id).toList();
    userExpenses.removeWhere((e) => e.id == id);
    _allExpenses[username] = userExpenses;

    // Jika expense dimiliki oleh username (owner), hapus dari owner storage juga
    for (var e in toRemove) {
      if (e.owner == username) {
        final ownerExpenses = _allExpenses[username] ?? [];
        ownerExpenses.removeWhere((ex) => ex.id == id);
        _allExpenses[username] = ownerExpenses;
        await StorageService.saveExpenses(username, ownerExpenses);
      } else {
        // Jika bukan owner, kemungkinan user hanya melihat shared expense.
        // Kita tidak menghapus data owner di sini (tidak diizinkan).
      }
    }
  }

  // Unshare expense dari user tertentu
  static Future<void> unshareExpense(String ownerUsername, String expenseId, String targetUsername) async {
    final ownerExpenses = _allExpenses[ownerUsername] ?? [];
    final expenseIndex = ownerExpenses.indexWhere((e) => e.id == expenseId);
    
    if (expenseIndex != -1) {
      final expense = ownerExpenses[expenseIndex];
      final updatedSharedWith = List<String>.from(expense.sharedWith);
      updatedSharedWith.remove(targetUsername);
      
      final updatedExpense = Expense(
        id: expense.id,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        description: expense.description,
        owner: expense.owner,
        sharedWith: updatedSharedWith,
      );
      
      ownerExpenses[expenseIndex] = updatedExpense;
      _allExpenses[ownerUsername] = ownerExpenses;
      await StorageService.saveExpenses(ownerUsername, ownerExpenses);
      
      // Hapus dari cache target user
      final targetExpenses = _allExpenses[targetUsername] ?? [];
      targetExpenses.removeWhere((e) => e.id == expenseId && e.owner == ownerUsername);
      _allExpenses[targetUsername] = targetExpenses;
      
      // Sinkronisasi untuk semua user yang masih terlibat
      await syncSharedExpenses(updatedExpense);
    }
  }

  // Get owned expenses (expenses yang dimiliki user)
  static List<Expense> getOwnedExpenses(String username) {
    final allExpenses = _allExpenses[username] ?? [];
    return allExpenses.where((e) => e.owner == username).toList();
  }

  // Get shared expenses (expenses yang di-share ke user)
  static List<Expense> getSharedExpenses(String username) {
    final allExpenses = _allExpenses[username] ?? [];
    return allExpenses.where((e) => e.owner != username && e.sharedWith.contains(username)).toList();
  }
}
