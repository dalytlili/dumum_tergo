import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:9098/api';

  // Méthode pour l'enregistrement (register)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String genre,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      // Envoyer une requête POST à l'API
      final response = await http.post(
        Uri.parse('$_baseUrl/register'), // Endpoint d'enregistrement
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "genre": genre,
          "email": email,
          "mobile": mobile,
          "password": password,
        }),
      );

      // Vérifier la réponse
      if (response.statusCode == 200) {
        // Décoder la réponse JSON
        return jsonDecode(response.body);
      } else {
        // Gérer les erreurs HTTP
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les exceptions
      throw Exception('Erreur lors de l\'enregistrement: $e');
    }
  }
}