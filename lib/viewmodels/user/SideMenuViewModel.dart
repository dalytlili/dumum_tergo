import 'dart:convert';

import 'package:dumum_tergo/services/logout_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SideMenuViewModel with ChangeNotifier {
  final LogoutService logoutService;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isDarkMode = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _name = ''; // User name
  String _profileImageUrl = ''; // Profile image URL

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get name => _name;
  String get profileImageUrl => _profileImageUrl;

  SideMenuViewModel({required this.logoutService});

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<void> fetchUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      String? token = await storage.read(key: 'token');
      String? refreshToken = await storage.read(key: 'refreshToken');

      if (token == null || refreshToken == null) {
        throw Exception('Veuillez vous reconnecter');
      }

      // Première tentative
      var response = await _makeProfileRequest(token);

      // Si token expiré (401)
      if (response.statusCode == 401) {
        try {
          final newTokens = await _refreshToken(refreshToken);
          await _storeNewTokens(newTokens);
          response = await _makeProfileRequest(newTokens['accessToken']);
        } catch (e) {
          await _clearTokens();
          throw Exception('Session expirée, veuillez vous reconnecter');
        }
      }

      if (response.statusCode == 200) {
        await _processProfileResponse(response);
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> _makeProfileRequest(String token) async {
    return await http.get(
      Uri.parse('https://dumum-tergo-backend.onrender.com/api/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://dumum-tergo-backend.onrender.com/api/refresh-token'),
                   headers: {'Authorization': 'Bearer $refreshToken'},

      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'accessToken': data['accessToken'],
            'refreshToken': data['refreshToken'],
          };
        }
      }
      
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['msg'] ?? 'Échec du rafraîchissement');
    } catch (e) {
      print('Erreur _refreshToken: $e');
      rethrow;
    }
  }

  Future<void> _storeNewTokens(Map<String, dynamic> tokens) async {
    await Future.wait([
      storage.write(key: 'token', value: tokens['accessToken']),
      storage.write(key: 'refreshToken', value: tokens['refreshToken']),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      storage.delete(key: 'token'),
      storage.delete(key: 'refreshToken'),
      storage.delete(key: 'email'),
      storage.delete(key: 'password'),
    ]);
  }

  Future<void> _processProfileResponse(http.Response response) async {
    final jsonResponse = jsonDecode(response.body);
    
    if (jsonResponse.containsKey('data')) {
      final userData = jsonResponse['data'];
      _name = userData['name'] ?? 'Inconnu';
      
      // Gestion améliorée de l'URL de l'image
      if (userData['image'] == null || userData['image'].isEmpty) {
        _profileImageUrl = 'assets/images/default.png';
      } else if (userData['image'].startsWith('http')) {
        _profileImageUrl = userData['image'];
      } else {
        _profileImageUrl = 'https://res.cloudinary.com/dcs2edizr/image/upload/${userData['image']}';
      }

      notifyListeners();
    } else {
      throw Exception("Format de réponse invalide");
    }
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
        const SnackBar(content: Text('Logout successful!')),
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
    // Navigate to history page
  }

  void navigateToIACamping(BuildContext context) {
    // Navigate to IA Camping page
  }
}