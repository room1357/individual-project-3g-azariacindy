import 'dart:io';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import 'package:printing/printing.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  State<AdvancedExpenseListScreen> createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> filteredExpenses = [];
  List<String> categories = ['Semua'];
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadExpensesAndCategories();
  }

  Future<void> _loadExpensesAndCategories() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    await ExpenseService.loadData(user.username);
    final loadedCategories = await StorageService.loadCategories(user.username);

    setState(() {
      currentUsername = user.username;
      filteredExpenses = ExpenseService.getExpenses(user.username);
      categories = ['Semua', ...loadedCategories.map((c) => c.name)];
    });
  }

  void _filterExpenses() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    final all = ExpenseService.getExpenses(user.username);
    setState(() {
      filteredExpenses = all.where((expense) {
        final matchesSearch = searchController.text.isEmpty ||
            expense.title
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            expense.description
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        final matchesCategory =
            selectedCategory == 'Semua' || expense.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _calculateTotal(List<Expense> expenses) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    final avg =
        expenses.fold(0.0, (sum, e) => sum + e.amount) / expenses.length;
    return 'Rp ${avg.toStringAsFixed(0)}';
  }

  Future<void> _deleteExpense(String id) async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    await ExpenseService.deleteExpense(user.username, id);
    await _loadExpensesAndCategories();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengeluaran berhasil dihapus")),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final path = await ExportService.exportToPDF(filteredExpenses);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil export ke PDF: $path')),
      );

      await Printing.layoutPdf(onLayout: (_) async {
        final file = File(path);
        return await file.readAsBytes();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Advanced'),
        // Use theme AppBar colors
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export ke PDF',
            onPressed: _exportToPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _filterExpenses(),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = cat;
                            _filterExpenses();
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _calculateTotal(filteredExpenses)),
                _buildStatCard('Jumlah', '${filteredExpenses.length} item'),
                _buildStatCard(
                    'Rata-rata', _calculateAverage(filteredExpenses)),
              ],
            ),
          ),
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: expense.owner == currentUsername
                              ? const Icon(Icons.person, color: Colors.green)
                              : const Icon(Icons.share, color: Colors.blue),
                          title: Text(expense.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${expense.category} • ${expense.formattedDate}'),
                              if (expense.owner != currentUsername)
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (expense.owner == currentUsername) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditExpenseScreen(expense: expense),
                                      ),
                                    );
                                    if (result == true) {
                                      await _loadExpensesAndCategories();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Hapus Pengeluaran?"),
                                        content: const Text(
                                            "Apakah kamu yakin ingin menghapus data ini?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Batal"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Hapus"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      _deleteExpense(expense.id);
                                    }
                                  },
                                ),
                              ] else ...[
                                const Icon(Icons.lock, color: Colors.grey),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddExpenseScreen()),
          );
          if (result == true) {
            await _loadExpensesAndCategories();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
