import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import '../services/expense_service.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    // Pastikan data terbaru dimuat ketika screen pertama kali dibuka
    ExpenseService.loadData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseService.expenses; // ✅ ambil dari service

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: expenses.isEmpty
          ? const Center(child: Text("Belum ada pengeluaran"))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle: Text('${expense.category} • ${expense.formattedDate}'),
                    trailing: Text(
                      expense.formattedAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          if (result == true) {
            // ✅ refresh data setelah tambah pengeluaran baru
            await ExpenseService.loadData();
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
