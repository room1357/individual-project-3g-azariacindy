import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/onboarding/icon_onboarding1.png",
      "title": "Kelola Uang dengan Mudah!",
      "desc":
          "Catat setiap pengeluaran dan lihat kemana uang Anda pergi — dengan mudah dan indah.",
    },
    {
      "image": "assets/onboarding/icon_onboarding2.png",
      "title": "Rencanakan dengan Bijak, Belanja dengan Bahagia",
      "desc":
          "Tentukan batas pengeluaran, pantau budget Anda, dan nikmati mengelola keuangan dengan senyuman.",
    },
    {
      "image": "assets/onboarding/icon_onboarding3.png",
      "title": "Impian Anda Layak Direncanakan",
      "desc":
          "Buat tujuan menabung dan saksikan progres Anda berkembang setiap hari.",
    },
    {
      "image": "assets/onboarding/icon_onboarding4.png",
      "title": "Semua Dompet, Satu Tempat",
      "desc":
          "Hubungkan akun, tabungan, atau e-wallet Anda, semuanya dalam PinkPocket.",
    },
    {
      "image": "assets/onboarding/icon_onboarding5.png",
      "title": "Lihat Uang Anda dengan Jelas",
      "desc":
          "Dari pengeluaran hingga menabung, PinkPocket mengatur semuanya agar Anda fokus pada yang Anda cintai.",
    },
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(fromOnboarding: true)),
    );
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 280,
                          child: Image.asset(
                            data["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          data["title"]!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // Description
                        Text(
                          data["desc"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFE91E63)
                          : const Color(0xFFFFB3BA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == onboardingData.length - 1 ? "Mulai!" : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
