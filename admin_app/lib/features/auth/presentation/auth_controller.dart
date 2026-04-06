import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final teacherDocs = await Firestore.instance
          .collection('admin')
          .where('Username', isEqualTo: username)
          .where('Password', isEqualTo: password)
          .get();

      if (teacherDocs.isEmpty) {
        _errorMessage = 'Invalid username or password';
        _isAuthenticated = false;
      } else {
        _errorMessage = null;
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
