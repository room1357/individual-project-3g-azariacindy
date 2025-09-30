import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  // Controller untuk input
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  // Variabel kategori
  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();

    // Isi default dari data expense yang sedang di-edit
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    selectedCategory = widget.expense.category;

    // 🔑 Load kategori dari StorageService
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loaded = await StorageService.loadCategories();
    setState(() {
      categories = loaded.map((c) => c.name).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengeluaran'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),

            // Input jumlah
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),

            // Dropdown kategori
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
            ),

            // Input deskripsi
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),

            const SizedBox(height: 20),

            // Tombol update
            ElevatedButton(
              onPressed: () async {
                // Buat objek expense hasil edit
                final updatedExpense = Expense(
                  id: widget.expense.id, // id tetap sama
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0,
                  category: selectedCategory ?? widget.expense.category,
                  date: widget.expense.date, // tanggal tetap
                  description: _descriptionController.text,
                );

                // 🔑 Simpan perubahan lewat ExpenseService
                await ExpenseService.updateExpense(updatedExpense);

                // Balik ke screen sebelumnya, kirim true agar refresh
                Navigator.pop(context, true);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
