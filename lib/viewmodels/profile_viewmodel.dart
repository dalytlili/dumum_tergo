import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfileViewModel with ChangeNotifier {
  String name = ''; // Nom de l'utilisateur
  String profileImageUrl = ''; // URL de l'image de profil
  bool isLoading = true; // Indicateur de chargement
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> fetchProfileData() async {
    try {
      String? token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        print('Token not found');
        return;
      }

      print('Token récupéré: $token');

      final response = await http.get(
        Uri.parse('http://127.0.0.1:9098/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data')) {
          final Map<String, dynamic> userData = jsonResponse['data'];

          name = userData['name'] ?? 'Inconnu';
          profileImageUrl = userData['image'] != null &&
                  userData['image'].startsWith('http')
              ? userData['image']
                  .replaceAll(RegExp(r'width=\d+&height=\d+'), 'width=200&height=200')
              : "http://127.0.0.1:9098${userData['image'] ?? '/images/default.png'}";

          print('Nom: $name, Image: $profileImageUrl');

          // Notifier l'UI du changement
          notifyListeners();
        } else {
          throw Exception("Données utilisateur non trouvées");
        }
      } else {
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // Notifier du changement de l'état de chargement
    }
  }
}
