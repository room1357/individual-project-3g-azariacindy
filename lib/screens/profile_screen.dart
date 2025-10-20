import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? currentUser;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getCurrentUser();
    if (user != null) {
      setState(() {
        currentUser = user;
        _usernameController = TextEditingController(text: user.username);
        _emailController = TextEditingController(text: user.email);
        _passwordController = TextEditingController(text: user.password);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (currentUser == null) return;

    final updatedUser = AppUser(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    await StorageService.updateUser(currentUser!, updatedUser);
    await StorageService.saveCurrentUser(updatedUser);

    setState(() {
      currentUser = updatedUser;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui!")),
    );
  }

  Future<void> _deleteAccount() async {
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: const Text(
            "Apakah kamu yakin ingin menghapus akun ini? Semua data pengeluaran dan kategori akan hilang permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.deleteAccount(currentUser!.username);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dihapus 😢"),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        // Use theme AppBar colors
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (val) => val == null || val.isEmpty
                    ? "Username tidak boleh kosong"
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) => val == null || val.isEmpty
                    ? "Email tidak boleh kosong"
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                enabled: _isEditing,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (val) => val == null || val.isEmpty
                    ? "Password tidak boleh kosong"
                    : null,
              ),
              const SizedBox(height: 20),

              // ✅ Tombol Simpan Perubahan
              if (_isEditing)
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text("Simpan Perubahan"),
                ),

              const SizedBox(height: 20),

              // 🔥 Tombol Hapus Akun
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _deleteAccount,
                label: const Text("Hapus Akun"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
