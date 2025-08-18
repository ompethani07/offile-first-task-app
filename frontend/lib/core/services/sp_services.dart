import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpServices {
  /// Save token in SharedPreferences
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('X-auth-token', token);
    debugPrint('✅ Token saved: $token');
  }

  /// Retrieve token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('X-auth-token');
    debugPrint('🔑 Token retrieved: $token');
    return token;
  }

  /// Remove token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('X-auth-token');
    debugPrint('🗑️ Token cleared');
  }
}
