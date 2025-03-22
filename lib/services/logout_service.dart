import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LogoutService {
  final String apiUrl = 'http://127.0.0.1:9098/api/logout';
  final String apiUrlSeller = 'http://127.0.0.1:9098/api/vendor/logout';

  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> logout(String token) async { // Ajoutez le paramètre token
    try {
      // Lister toutes les valeurs stockées pour vérification
      final allValues = await storage.readAll();
      print('Toutes les valeurs stockées: $allValues');

      // Récupérer le token d'accès depuis le stockage sécurisé
      final token = await storage.read(key: 'token'); // Utilisez la clé 'token'
      print('Token récupéré: $token'); // Vérifiez ce qui est affiché dans la console

      // Vérifier si le token est valide
      if (token == null || token.isEmpty) {
        throw Exception('Aucun token trouvé pour la déconnexion');
      }

      // Envoyer une requête POST pour la déconnexion
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Vérifier la réponse du serveur
      if (response.statusCode == 200) {
        // Supprimer tous les tokens du stockage sécurisé
        await storage.delete(key: 'token'); // Supprimez le token avec la clé 'token'
        await storage.delete(key: 'refreshToken');

        print('Déconnexion réussie.');
      } else {
        throw Exception(
            'Erreur lors de la déconnexion: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }
   Future<void> logoutSeller(String token) async {
  try {
    // Récupérer le token depuis le stockage sécurisé
    final token = await storage.read(key: 'seller_token'); // Utilisez la clé 'seller_token'
    print('Token récupéré: $token'); // Vérifiez ce qui est affiché dans la console

    // Vérifier si le token est valide
    if (token == null || token.isEmpty) {
      throw Exception('Aucun token trouvé pour la déconnexion');
    }

    // Envoyer une requête GET pour la déconnexion
    final response = await http.get(
      Uri.parse(apiUrlSeller),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      // Supprimer le token et le refreshToken depuis le stockage sécurisé
      await storage.delete(key: 'seller_token'); // Supprimez le token avec la clé 'seller_token'
      await storage.delete(key: 'refreshToken'); // Supprimez aussi le refreshToken si présent

      print('Déconnexion réussie.');
    } else {
      throw Exception(
          'Erreur lors de la déconnexion: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Erreur lors de la déconnexion: $e');
    throw Exception('Erreur lors de la déconnexion: $e');
  }
}
}