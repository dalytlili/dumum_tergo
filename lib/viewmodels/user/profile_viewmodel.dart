import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfileViewModel with ChangeNotifier {
  String name = '';
  String profileImageUrl = '';
  bool isLoading = true;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> fetchProfileData() async {
    try {
      isLoading = true;
      notifyListeners();

      String? token = await storage.read(key: 'token');
      String? refreshToken = await storage.read(key: 'refreshToken');

      if (token == null || refreshToken == null) {
        throw Exception('Tokens non disponibles');
      }

      // Première tentative avec le token actuel
      var response = await _makeProfileRequest(token);

      // Si le token a expiré (401), on le rafraîchit
      if (response.statusCode == 401) {
        print('Token expiré, tentative de rafraîchissement...');
        final newTokens = await _refreshToken(refreshToken);
        
        // On stocke les nouveaux tokens
        await storage.write(key: 'token', value: newTokens['accessToken']);
        await storage.write(key: 'refreshToken', value: newTokens['refreshToken']);
        
        // On relance la requête avec le nouveau token
        response = await _makeProfileRequest(newTokens['accessToken']);
      }

      if (response.statusCode == 200) {
        await _processProfileResponse(response);
      } else {
        throw Exception('Échec du chargement: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> _makeProfileRequest(String token) async {
    return await http.get(
      Uri.parse('http://127.0.0.1:9098/api/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:9098/api/refresh-token'),
           headers: {'Authorization': 'Bearer $refreshToken'},

    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec du rafraîchissement du token');
    }
  }

  Future<void> _processProfileResponse(http.Response response) async {
    final jsonResponse = json.decode(response.body);
    
    if (jsonResponse.containsKey('data')) {
      final userData = jsonResponse['data'];
      name = userData['name'] ?? 'Inconnu';
      
      profileImageUrl = userData['image']?.toString().startsWith('http') ?? false
          ? userData['image']
              .replaceAll(RegExp(r'width=\d+&height=\d+'), 'width=200&height=200')
          : "http://127.0.0.1:9098${userData['image'] ?? '/images/default.png'}";

      notifyListeners();
    } else {
      throw Exception("Format de réponse invalide");
    }
  }
}