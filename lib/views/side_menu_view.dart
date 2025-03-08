

import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/viewmodels/SideMenuViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';

class SideMenuView extends StatelessWidget {
  const SideMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: themeViewModel.isDarkMode ? Colors.grey[700]! : AppColors.primary,
          width: 0, // Bordure invisible (largeur 0)
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(70), // Coin supérieur droit arrondi à 70
          bottomRight: Radius.circular(70), // Coin inférieur droit arrondi à 70
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(70), // Coin supérieur droit arrondi à 70
          bottomRight: Radius.circular(70), // Coin inférieur droit arrondi à 70
        ),
        child: Drawer(
          width: 280, // Largeur du menu à 280 pixels
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // En-tête du Drawer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeViewModel.isDarkMode ? Colors.grey[900] : AppColors.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton de retour
                    const SizedBox(height: 30), // Espacement

                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Fermer le menu latéral
                      },
                    ),
                    const SizedBox(height: 10), // Espacement

                    // Photo de l'utilisateur
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/images.png'),
                    ),
                    const SizedBox(height: 10), // Espacement

                    // Nom de l'utilisateur
                    const Text(
                      'Daly Tilii',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5), // Espacement

                    // E-mail de l'utilisateur
                    const Text(
                      'mohammedali.tilii@esprit.tn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Éléments du menu
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History'),
                onTap: () {
                  // Naviguer vers la page d'histoire
                },
              ),
              ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text('IA Camping'),
                onTap: () {
                  // Naviguer vers la page IA Camping
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('À propos de nous'),
                onTap: () {
                  // Naviguer vers la page "À propos de nous"
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  // Naviguer vers la page des paramètres
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Aide et support'),
                onTap: () {
                  // Naviguer vers la page d'aide et support
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Se déconnecter'),
                onTap: () {
                  // Logique pour se déconnecter
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour afficher une boîte de dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    final sideMenuViewModel = Provider.of<SideMenuViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final token = await sideMenuViewModel.getToken();
                if (token != null) {
                  await sideMenuViewModel.logoutUser(context, token);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token not found')),
                  );
                }
              },
              child: const Text('Déconnecter'),
            ),
          ],
        );
      },
    );
  }
}