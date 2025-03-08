import 'package:dumum_tergo/viewmodels/HomeViewModel.dart';
import 'package:dumum_tergo/views/side_menu_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'animated_nav_bar.dart';
import 'profile_view.dart'; // Importez ProfileView

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Liste des écrans à afficher en fonction de l'index
  final List<Widget> _screens = [
    const Placeholder(), // Écran d'accueil
    const Placeholder(), // Écran de recherche (à remplacer)
    const Placeholder(), 
        const Placeholder(), // Écran des likes (à remplacer)
// Écran des likes (à remplacer)
    ProfileView(), // Écran du profil
  ];

  // Liste des titres correspondant à chaque écran
  final List<String> _appBarTitles = [
    'Accueil', // Titre pour l'écran d'accueil
    'Recherche', // Titre pour l'écran de recherche
    'Likes',
    'Metieo', // Titre pour l'écran des likes
    'Profil', // Titre pour l'écran du profil
  ];

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitles[_currentIndex]), // Titre dynamique
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () async {
                // Action pour les notifications
              },
            ),
          ],
        ),
        drawer: const SideMenuView(),
        body: AnimatedNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Mettre à jour l'index actuel
            });
          },
          isDarkMode: themeViewModel.isDarkMode,
          screens: _screens, // Passez les écrans ici
        ),
      ),
    );
  }
}