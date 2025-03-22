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
    // Récupérer le token depuis le stockage sécurisé
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      print('Token not found');
      return;
    }

    // Faire la requête HTTP pour récupérer les données de l'utilisateur
    final response = await http.get(
      Uri.parse('http://127.0.0.1:9098/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Décoder la réponse JSON
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Vérifier que 'data' existe bien
      if (jsonResponse.containsKey('data')) {
        final Map<String, dynamic> userData = jsonResponse['data'];

        // Mettre à jour les données avec une valeur par défaut si null
        _name = userData['name'] ?? 'Inconnu';

        // Vérifier si l'URL de l'image est valide
       if (userData['image'] != null) {
  // Vérifier si l'URL est valide et contient un chemin spécifique
  if (userData['image'].startsWith('http://127.0.0.1:9098')) {
    if (userData['image'] == 'http://127.0.0.1:9098') {
      // Si l'URL est exactement "http://127.0.0.1:9098", utiliser l'image par défaut
      _profileImageUrl = 'assets/images/images.png';
    } 
  } else if (userData['image'].startsWith('http')) {
    // Si l'URL est une URL complète différente de "http://127.0.0.1:9098", afficher l'image depuis l'URL
    _profileImageUrl = userData['image'];
  } else {
    // Si l'URL est invalide ou vide, utiliser l'image par défaut
    _profileImageUrl = 'http://127.0.0.1:9098' + userData['image'];
  }
} else {
  // Si 'image' est null ou vide, utiliser l'image par défaut
    _profileImageUrl = userData['image'];
}


        print('Nom: $_name, Image: $_profileImageUrl');
      } else {
        throw Exception("Données utilisateur non trouvées");
      }
    } else {
      throw Exception('Failed to load profile data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    _errorMessage = 'Échec du chargement des données utilisateur';
  } finally {
    _isLoading = false;
    notifyListeners(); // Notifier les écouteurs que les données ont été mises à jour
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