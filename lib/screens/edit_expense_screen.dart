import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../services/expense_service.dart';
import '../models/user.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  String? selectedCategory;
  List<String> categories = [];
  AppUser? currentUser;

  // keep sharedWith editable
  List<String> allUsernames = [];
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    selectedCategory = widget.expense.category;
    selectedUsers = List<String>.from(widget.expense.sharedWith);

    _loadUserAndCategories();
  }

  Future<void> _loadUserAndCategories() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;
    final loaded = await StorageService.loadCategories(user.username);
    final usernames = await StorageService.getAllUsernames();
    usernames.remove(user.username);

    setState(() {
      currentUser = user;
      categories = loaded.map((c) => c.name).toList();
      allUsernames = usernames;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengeluaran'),
        // Use theme AppBar colors
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),

            const SizedBox(height: 10),
            if (allUsernames.isNotEmpty) ...[
              const Align(alignment: Alignment.centerLeft, child: Text('Bagikan dengan pengguna lain:')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: allUsernames.map((username) {
                  final sel = selectedUsers.contains(username);
                  return FilterChip(
                    label: Text(username),
                    selected: sel,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          if (!selectedUsers.contains(username)) selectedUsers.add(username);
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
                if (currentUser == null) return;

                final updatedExpense = Expense(
                  id: widget.expense.id,
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0,
                  category: selectedCategory ?? widget.expense.category,
                  date: widget.expense.date,
                  description: _descriptionController.text,
                  owner: widget.expense.owner,
                  sharedWith: selectedUsers,
                );

                await ExpenseService.updateExpense(
                  currentUser!.username,
                  updatedExpense,
                );

                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
