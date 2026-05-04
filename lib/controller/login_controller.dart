import 'package:flutter/material.dart';
import 'package:screen_arts_app/service/login_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  // ─── Session fields ────────────────────────────────────────────────────────
  String? sid;
  String? fullName;
  String? employeeId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => sid != null;

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      _userData = result;

      // Read back values that were persisted by AuthService
      final session = await _authService.loadSession();
      sid = session['sid'];
      fullName = session['full_name'];
      employeeId = session['employee_id'];
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Restore session on app start ─────────────────────────────────────────
  Future<void> restoreSession() async {
    final session = await _authService.loadSession();
    sid = session['sid'];
    fullName = session['full_name'];
    employeeId = session['employee_id'];
    notifyListeners();
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.clearSession();
    sid = null;
    fullName = null;
    employeeId = null;
    _userData = null;
    _error = null;
    notifyListeners();
  }
}
