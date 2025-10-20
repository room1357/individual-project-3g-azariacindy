import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories(); // load data saat screen dibuka
  }

  Future<void> _loadCategories() async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    // Pastikan user punya kategori default
    await StorageService.ensureDefaultCategories(user.username);

    categories = await StorageService.loadCategories(user.username);
    setState(() {});
  }

  Future<void> _addCategory(String name) async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    categories.add(newCategory);
    await StorageService.saveCategories(user.username, categories);
    setState(() {});
  }

  Future<void> _editCategory(Category category, String newName) async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    int index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = Category(id: category.id, name: newName);
      await StorageService.saveCategories(user.username, categories);
      setState(() {});
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final user = await StorageService.getCurrentUser();
    if (user == null) return;

    categories.removeWhere((c) => c.id == category.id);
    await StorageService.saveCategories(user.username, categories);
    setState(() {});
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama kategori"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _addCategory(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Kategori"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _editCategory(category, controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Kategori"),
        // Use theme AppBar colors
      ),
      body: categories.isEmpty
          ? const Center(child: Text("Belum ada kategori"))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showEditDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(category),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
