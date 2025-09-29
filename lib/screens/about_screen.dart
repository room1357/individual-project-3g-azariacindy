import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), backgroundColor: Colors.blue),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Aplikasi Pengeluaran - versi 1.0\nDibuat untuk latihan pemrograman mobile.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
