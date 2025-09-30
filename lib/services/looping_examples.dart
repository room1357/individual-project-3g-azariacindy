import '../models/expense.dart';

class LoopingExamples {
  static List<Expense> expenses = [
    Expense(
      id: '1',
      title: 'Belanja Bulanan',
      amount: 150000,
      category: 'Makanan',
      date: DateTime(2024, 9, 15),
      description: 'Belanja kebutuhan bulanan di supermarket',
    ),
    Expense(
      id: '2',
      title: 'Bensin Motor',
      amount: 50000,
      category: 'Transportasi',
      date: DateTime(2024, 9, 14),
      description: 'Isi bensin motor untuk transportasi',
    ),
    Expense(
      id: '3',
      title: 'Tagihan Internet',
      amount: 300000,
      category: 'Utilitas',
      date: DateTime(2024, 9, 10),
      description: 'Bayar tagihan internet bulanan',
    ),
  ];

  // 1. Menghitung total pengeluaran
  // Cara 1: For loop tradisional
  static double calculateTotalTraditional(List<Expense> expenses) {
    double total = 0.0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  // Cara 2: For-in loop
  static double calculateTotalForIn(List<Expense> expenses) {
    double total = 0.0;
    for (Expense expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Cara 3: forEach method
  static double calculateTotalForEach(List<Expense> expenses) {
    double total = 0.0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  // Cara 4: fold method (paling ringkas)
  static double calculateTotalFold(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Cara 5: reduce method
  static double calculateTotalReduce(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 2. Mencari item berdasarkan id
  // Cara 1: For loop dengan break
  static Expense? findExpenseTraditional(List<Expense> expenses, String id) {
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].id == id) {
        return expenses[i];
      }
    }
    return null;
  }

  // Cara 2: firstWhere method
  static Expense? findExpenseWhere(List<Expense> expenses, String id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. Filtering berdasarkan kategori
  // Cara 1: Loop manual dengan List.add()
  static List<Expense> filterByCategoryManual(List<Expense> expenses, String category) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  // Cara 2: where method (lebih singkat)
  static List<Expense> filterByCategoryWhere(List<Expense> expenses, String category) {
    return expenses
        .where((expense) => expense.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
