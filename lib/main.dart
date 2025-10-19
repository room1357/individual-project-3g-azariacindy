import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 
import 'services/storage_service.dart';
import 'services/expense_service.dart';
import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ambil user yang sedang login (kalau ada)
  final AppUser? currentUser = await StorageService.getCurrentUser();

  // Kalau user sudah login, langsung load datanya
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
      title: 'Pink Pocket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // tampilan awal aplikasi
    );
  }
}
