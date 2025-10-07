import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/expense_service.dart';
// import 'services/expense_manager.dart';
// import 'services/looping_examples.dart'; 

Future<void> main() async {
  // ExpenseManager 
  // print(ExpenseManager.getTotalByCategory(ExpenseManager.expenses));
  // print(ExpenseManager.getHighestExpense(ExpenseManager.expenses)?.title);
  // print(ExpenseManager.getExpensesByMonth(ExpenseManager.expenses, 9, 2024));
  // print(ExpenseManager.searchExpenses(ExpenseManager.expenses, "internet"));
  // print(ExpenseManager.getAverageDaily(ExpenseManager.expenses));

  // LoopingExamples 
  // print("Total (for): ${LoopingExamples.calculateTotalTraditional(LoopingExamples.expenses)}");
  // print("Total (for-in): ${LoopingExamples.calculateTotalForIn(LoopingExamples.expenses)}");
  // print("Total (forEach): ${LoopingExamples.calculateTotalForEach(LoopingExamples.expenses)}");
  // print("Total (fold): ${LoopingExamples.calculateTotalFold(LoopingExamples.expenses)}");
  // print("Total (reduce): ${LoopingExamples.calculateTotalReduce(LoopingExamples.expenses)}");

  // print("Cari id=2: ${LoopingExamples.findExpenseTraditional(LoopingExamples.expenses, '2')?.title}");
  // print("Cari id=3: ${LoopingExamples.findExpenseWhere(LoopingExamples.expenses, '3')?.title}");

  // print("Filter kategori 'Makanan': ${LoopingExamples.filterByCategoryWhere(LoopingExamples.expenses, 'Makanan').length} item");

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ExpenseService.loadData();
  } catch (e) {
    print("Gagal load data: $e");
  }

  // Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pengeluaran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(), // Halaman pertama
    );
  }
}
