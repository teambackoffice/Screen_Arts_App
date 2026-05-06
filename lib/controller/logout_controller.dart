import 'package:flutter/material.dart';
import 'package:screen_arts_app/service/logout_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogoutController with ChangeNotifier {
  final LogoutService _service = LogoutService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = false;

  Future<bool> logout(String username) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _service.logout(username: username);
      print("✅ Logout Success: $response");

      // ✅ Clear ALL secure storage keys, not just sid
      await _storage.deleteAll();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print("❌ Logout Error: $e");
      return false;
    }
  }
}
