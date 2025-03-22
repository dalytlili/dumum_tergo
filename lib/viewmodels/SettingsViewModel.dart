import 'package:dumum_tergo/views/EditProfileView.dart';
import 'package:dumum_tergo/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dumum_tergo/viewmodels/EditProfileViewModel.dart'; // Importez le ViewModel de modification du profil
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsViewModel with ChangeNotifier {
  // Méthode pour gérer le changement de mot de passe
  void changePassword(BuildContext context) {
    // Naviguer vers la page de changement de mot de passe
    Navigator.pushNamed(context, '/changePassword');
  }

  // Méthode pour modifier le profil
  void editProfile(BuildContext context) {
    final editProfileViewModel = Provider.of<EditProfileViewModel>(context, listen: false);

    // Récupérer les données du profil avant d'ouvrir la modal
    editProfileViewModel.fetchProfileData().then((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Permet à la modal de s'adapter au clavier
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste la hauteur pour le clavier
            ),
            child: EditProfileView(), // Afficher la vue de modification du profil
          );
        },
      );
    });
  }

  // Méthode pour gérer le changement de langue
  void changeLanguage(BuildContext context) {
    // Naviguer vers la page de changement de langue
    //Navigator.pushNamed(context, '/changeLanguage');
  }

  // Méthode pour afficher la politique de confidentialité
  void showPrivacyPolicy(BuildContext context) {
    // Naviguer vers la page de politique de confidentialité
    //Navigator.pushNamed(context, '/privacyPolicy');
  }

  // Méthode pour contacter le support
  void contactUs(BuildContext context) {
    // Naviguer vers la page de contact
    //Navigator.pushNamed(context, '/contactUs');
  }

  // Méthode pour supprimer le compte
  void deleteAccount(BuildContext context) {
    // Afficher une boîte de dialogue pour demander le mot de passe
showDialog(
  context: context,
  builder: (context) {
    final _passwordController = TextEditingController();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red), // Icône d'avertissement
          SizedBox(width: 10),
          Text('Attention', style: TextStyle(color: Colors.red)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚠️ Cette action est irréversible !',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 10),
          Text('Êtes-vous sûr de vouloir supprimer définitivement votre compte ?'),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Bouton rouge pour supprimer
          ),
          onPressed: () async {
            final password = _passwordController.text;

            if (password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Veuillez entrer votre mot de passe')),
              );
              return;
            }

            String? token = await storage.read(key: 'token');

            final response = await http.delete(
              Uri.parse('http://127.0.0.1:9098/api/delete-account'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'password': password}),
            );

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Compte supprimé avec succès')),
              );

              // Rediriger vers l'écran de connexion
              Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la suppression du compte')),
              );
            }

            // Vérifier si la boîte de dialogue est toujours ouverte avant de la fermer
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Text('Supprimer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  },
);

  }
}