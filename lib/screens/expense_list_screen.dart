import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> expenses = [];
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    await ExpenseService.loadData(user.username);
    setState(() {
      currentUser = user;
      expenses = ExpenseService.getExpenses(user.username);
    });
  }

  Future<void> _refreshData() async {
    if (currentUser == null) return;
    await ExpenseService.loadData(currentUser!.username);
    setState(() {
      expenses = ExpenseService.getExpenses(currentUser!.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengeluaran'),
        // Use theme AppBar colors
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
                    leading: expense.owner == currentUser?.username
                        ? const Icon(Icons.person, color: Colors.green)
                        : const Icon(Icons.share, color: Colors.blue),
                    title: Text(expense.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${expense.category} • ${expense.formattedDate}'),
                        if (expense.owner != currentUser?.username)
                          Text(
                            'Dibagikan oleh: ${expense.owner}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
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
            await _refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
