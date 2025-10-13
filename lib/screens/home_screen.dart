import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'advanced_expense_list_screen.dart';
import 'catergory_screen.dart';
import 'statistics_screen.dart';
import '../services/expense_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await StorageService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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
        title: Text('Hello maniez, ${currentUser!.username}!'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard('Profil', Icons.person, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }),
                  _buildDashboardCard('Pengaturan', Icons.settings, Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }),
                  _buildDashboardCard('Pengeluaran Advanced', Icons.analytics, Colors.teal, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedExpenseListScreen(),
                      ),
                    );
                  }),
                  _buildDashboardCard('Kategori', Icons.category, Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    );
                  }),
                  _buildDashboardCard('Statistik', Icons.bar_chart, Colors.indigo, () async {
                    final user = await StorageService.getCurrentUser();
                    if (user == null) return;

                    final expenses = ExpenseService.getExpenses(user.username);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsScreen(expenses: expenses),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, Color color, VoidCallback? onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur $title segera hadir!')),
              );
            },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
