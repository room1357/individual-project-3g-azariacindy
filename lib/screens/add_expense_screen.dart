import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/expense_service.dart';
import '../services/storage_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();

  String? selectedCategory;
  List<Category> categories = [];

  // state untuk shared users
  List<String> allUsernames = [];
  List<String> selectedUsers = [];

  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    currentUsername = user.username;
    await StorageService.ensureDefaultCategories(user.username);
    categories = await StorageService.loadCategories(user.username);
    allUsernames = await StorageService.getAllUsernames();

    // hilangkan username current dari daftar opsi share
    allUsernames.remove(user.username);

    setState(() {});
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pengeluaran"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text("Pilih Kategori"),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c.name,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),

            const SizedBox(height: 10),

            // Bagian shared users
            if (allUsernames.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Bagikan dengan pengguna lain:"),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: allUsernames.map((username) {
                  final selected = selectedUsers.contains(username);
                  return FilterChip(
                    label: Text(username),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          selectedUsers.add(username);
                        } else {
                          selectedUsers.remove(username);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    selectedCategory == null ||
                    currentUsername == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
                  );
                  return;
                }

                final newExpense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  category: selectedCategory!,
                  date: DateTime.now(),
                  description: descController.text,
                  owner: currentUsername!,
                  sharedWith: selectedUsers,
                );

                await ExpenseService.addExpense(currentUsername!, newExpense);
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
