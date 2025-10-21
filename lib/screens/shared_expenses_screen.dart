import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart';
import 'edit_expense_screen.dart';

class SharedExpensesScreen extends StatefulWidget {
  const SharedExpensesScreen({super.key});

  @override
  State<SharedExpensesScreen> createState() => _SharedExpensesScreenState();
}

class _SharedExpensesScreenState extends State<SharedExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Expense> ownedExpenses = [];
  List<Expense> sharedExpenses = [];
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    await ExpenseService.loadData(user.username);
    setState(() {
      currentUsername = user.username;
      ownedExpenses = ExpenseService.getOwnedExpenses(user.username);
      sharedExpenses = ExpenseService.getSharedExpenses(user.username);
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _unshareExpense(Expense expense, String targetUsername) async {
    if (currentUsername == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Sharing"),
        content: Text("Apakah kamu yakin ingin menghapus sharing dengan $targetUsername?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ExpenseService.unshareExpense(currentUsername!, expense.id, targetUsername);
      await _refreshData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sharing dengan $targetUsername berhasil dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Expenses"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: "Milik Saya",
            ),
            Tab(
              icon: Icon(Icons.share),
              text: "Dibagikan ke Saya",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Owned Expenses
          _buildOwnedExpensesTab(),
          // Tab 2: Shared Expenses
          _buildSharedExpensesTab(),
        ],
      ),
    );
  }

  Widget _buildOwnedExpensesTab() {
    if (ownedExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada pengeluaran",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              "Buat pengeluaran baru untuk mulai berbagi",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ownedExpenses.length,
        itemBuilder: (context, index) {
          final expense = ownedExpenses[index];
          return _buildOwnedExpenseCard(expense);
        },
      ),
    );
  }

  Widget _buildSharedExpensesTab() {
    if (sharedExpenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada pengeluaran yang dibagikan",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              "Pengeluaran yang dibagikan ke Anda akan muncul di sini",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sharedExpenses.length,
        itemBuilder: (context, index) {
          final expense = sharedExpenses[index];
          return _buildSharedExpenseCard(expense);
        },
      ),
    );
  }

  Widget _buildOwnedExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category} • ${expense.formattedDate}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  expense.formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (expense.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                expense.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            if (expense.sharedWith.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.share, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text(
                    "Dibagikan ke: ",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: expense.sharedWith.map((username) {
                        return Chip(
                          label: Text(
                            username,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.shade50,
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _unshareExpense(expense, username),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditExpenseScreen(expense: expense),
                      ),
                    );
                    if (result == true) {
                      await _refreshData();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.share, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category} • ${expense.formattedDate}',
                        style: const TextStyle(color: Colors.grey),
                      ),
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
                ),
                Text(
                  expense.formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (expense.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                expense.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
