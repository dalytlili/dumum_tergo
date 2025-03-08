import 'package:dumum_tergo/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dumum_tergo/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../services/logout_service.dart';

class SideMenuViewModel with ChangeNotifier {
  final LogoutService logoutService;
  bool _isDarkMode = false;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  SideMenuViewModel({required this.logoutService});

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> logoutUser(BuildContext context, String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await logoutService.logout(token);
      await storage.delete(key: 'email');
      await storage.delete(key: 'password');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie !')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } on Exception catch (e) {
      _errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void navigateToHistory(BuildContext context) {
    // Naviguer vers la page d'histoire
  }

  void navigateToIACamping(BuildContext context) {
    // Naviguer vers la page IA Camping
  }
}
