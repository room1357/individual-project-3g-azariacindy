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
  // Controller untuk inputan
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();

  // Variabel kategori
  String? selectedCategory;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories(); // 🔑 Load kategori dari StorageService
  }

  // Fungsi load kategori dari SharedPreferences
  Future<void> _loadCategories() async {
    categories = await StorageService.loadCategories();
    setState(() {}); // update UI setelah kategori dimuat
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
            // Input judul
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),

            // Input harga
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),

            // Dropdown kategori
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

            // Input deskripsi
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),

            const SizedBox(height: 20),

            // Tombol simpan
            ElevatedButton(
              onPressed: () async {
                // Validasi input
                if (titleController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    selectedCategory == null) {
                  return;
                }

                // Buat objek expense baru
                final newExpense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  category: selectedCategory!,
                  date: DateTime.now(),
                  description: descController.text,
                );

                // 🔑 Simpan expense ke storage lewat ExpenseService
                await ExpenseService.addExpense(newExpense);

                // Balik ke screen sebelumnya, kirim status true agar refresh
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
