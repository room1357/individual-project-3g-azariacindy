import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'onboarding_screen.dart';
import '../utils/onboarding_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Onboarding section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFFE91E63)),
            title: const Text('Lihat Onboarding'),
            subtitle: const Text('Lihat kembali pengenalan aplikasi PinkPocket'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              // Reset onboarding status dan navigasi ke onboarding
              await OnboardingUtils.resetOnboarding();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                );
              }
            },
          ),
          const Divider(),
          
          // About section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Informasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFFE91E63)),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Informasi tentang PinkPocket'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
