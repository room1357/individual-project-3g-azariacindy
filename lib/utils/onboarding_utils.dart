import 'package:shared_preferences/shared_preferences.dart';

class OnboardingUtils {
  /// Reset onboarding status untuk testing
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', false);
  }
  
  /// Check apakah user sudah melihat onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }
  
  /// Mark onboarding sebagai sudah dilihat
  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }
}
