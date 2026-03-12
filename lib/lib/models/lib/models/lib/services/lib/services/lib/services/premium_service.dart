import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _key = 'is_premium';
  static const String validCode = '150218551';

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<bool> activateCode(String code) async {
    if (code == validCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      return true;
    }
    return false;
  }
}
