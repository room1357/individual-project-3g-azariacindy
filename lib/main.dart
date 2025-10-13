import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/expense_service.dart';
import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ambil user yang sedang login
  final AppUser? currentUser = await StorageService.getCurrentUser();

  // Kalau ada user login, langsung load datanya
  if (currentUser != null) {
    await ExpenseService.loadData(currentUser.username);
  }

  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  final AppUser? currentUser;
  const MyApp({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pengeluaran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: currentUser != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
