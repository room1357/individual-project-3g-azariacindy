import 'package:flutter/material.dart';
import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar'),
        backgroundColor: Colors.blue,
      ),
      body: Center( // <- Tambahkan Center di sini
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // vertikal tengah
            crossAxisAlignment: CrossAxisAlignment.center, // horizontal tengah
            children: [
              // Form fields...

              // Tombol register
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke HomeScreen dengan pushReplacement
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Text('DAFTAR'),
              ),

              SizedBox(height: 8), // beri jarak sedikit

              // Link kembali ke login
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke LoginScreen
                },
                child: Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
