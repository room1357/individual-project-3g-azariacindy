// import '../models/expense.dart';

// class ExpenseManager {
//   static List<Expense> expenses = [
//     // Contoh data dummy, bisa kamu isi dari ExpenseListScreen juga
//     Expense(
//       id: '1',
//       title: 'Belanja Bulanan',
//       amount: 150000,
//       category: 'Makanan',
//       date: DateTime(2024, 9, 15),
//       description: 'Belanja kebutuhan bulanan di supermarket',
//     ),
//     Expense(
//       id: '2',
//       title: 'Bensin Motor',
//       amount: 50000,
//       category: 'Transportasi',
//       date: DateTime(2024, 9, 14),
//       description: 'Isi bensin motor untuk transportasi',
//     ),
//     Expense(
//       id: '3',
//       title: 'Tagihan Internet',
//       amount: 300000,
//       category: 'Utilitas',
//       date: DateTime(2024, 9, 10),
//       description: 'Bayar tagihan internet bulanan',
//     ),
//   ];

//   /// 1. Mendapatkan total pengeluaran per kategori
//   static Map<String, double> getTotalByCategory(List<Expense> expenses) {
//     Map<String, double> result = {};
//     for (var expense in expenses) {
//       result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
//     }
//     return result;
//   }

//   /// 2. Mendapatkan pengeluaran tertinggi
//   static Expense? getHighestExpense(List<Expense> expenses) {
//     if (expenses.isEmpty) return null;
//     return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
//   }

//   /// 3. Mendapatkan pengeluaran bulan tertentu
//   static List<Expense> getExpensesByMonth(List<Expense> expenses, int month, int year) {
//     return expenses.where((expense) =>
//       expense.date.month == month && expense.date.year == year
//     ).toList();
//   }

//   /// 4. Mencari pengeluaran berdasarkan kata kunci
//   static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
//     String lowerKeyword = keyword.toLowerCase();
//     return expenses.where((expense) =>
//       expense.title.toLowerCase().contains(lowerKeyword) ||
//       expense.description.toLowerCase().contains(lowerKeyword) ||
//       expense.category.toLowerCase().contains(lowerKeyword)
//     ).toList();
//   }

//   /// 5. Mendapatkan rata-rata pengeluaran harian
//   static double getAverageDaily(List<Expense> expenses) {
//     if (expenses.isEmpty) return 0;

//     double total = expenses.fold(0, (sum, expense) => sum + expense.amount);

//     // Hitung jumlah hari unik
//     Set<String> uniqueDays = expenses.map((expense) =>
//       '${expense.date.year}-${expense.date.month}-${expense.date.day}'
//     ).toSet();

//     return total / uniqueDays.length;
//   }
// }
