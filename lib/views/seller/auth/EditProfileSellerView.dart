import 'package:country_picker/country_picker.dart';
import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/services/auth_service.dart';
import 'package:dumum_tergo/services/logout_service.dart';
import 'package:dumum_tergo/views/user/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dumum_tergo/viewmodels/seller/EditProfileSellerViewModel.dart';
import 'dart:io';

class EditProfileSellerView extends StatefulWidget {
  const EditProfileSellerView({super.key});

  @override
  _EditProfileSellerViewState createState() => _EditProfileSellerViewState();
}

class _EditProfileSellerViewState extends State<EditProfileSellerView> {
    final LogoutService _logoutService = LogoutService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    // Appeler fetchProfileData pour récupérer les données de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditProfileSellerViewModel>(context, listen: false).fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditProfileSellerViewModel>(context, listen: true);

    return Scaffold(
            appBar: AppBar(
        title: const Text('Modifier le profil', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05, // 10% de la largeur de l'écran
          vertical: 30.0, // Garder le padding vertical fixe
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileImage(viewModel),
            const SizedBox(height: 10),
            // Afficher le temps restant avant l'expiration
           RichText(
  text: TextSpan(
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.grey[700], // Couleur par défaut
    ),
    children: [
      const TextSpan(text: 'Temps restant avant expiration : '),
      TextSpan(
        text: viewModel.remainingSubscriptionTime,
        style: TextStyle(
          color: Colors.red, // Couleur personnalisée pour le temps restant
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.adressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: viewModel.phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Numéro de téléphone',
                prefixIcon: InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          viewModel.selectedCountry = country;
                        });
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewModel.selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${viewModel.selectedCountry.phoneCode}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre numéro de téléphone';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Veuillez entrer un numéro valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, // Prend toute la largeur disponible
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null // Désactive le bouton pendant le chargement
                    : () async {
                        await viewModel.updateProfile(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator() // Affiche un indicateur de chargement
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher et modifier l'image de profil
  Widget _buildProfileImage(EditProfileSellerViewModel viewModel) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _getImage(viewModel.imageUrlController.text),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              viewModel.imageUrlController.text = pickedFile.path;
              viewModel.notifyListeners();
            }
          },
        ),
      ],
    );
  }
 void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
                   onPressed: () async {
      final token = await storage.read(key: 'seller_token');
                if (token != null) {
      await _logoutService.logoutSeller(token);
           Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token not found')),
                  );
                }
              },
              child: const Text('Déconnexion', 
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  // Méthode pour obtenir l'image (depuis une URL ou un fichier local)
  ImageProvider _getImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl); // Si c'est une URL
      } else {
        // Vérification si c'est un fichier local
        final file = File(imageUrl);
        if (file.existsSync()) {
          return FileImage(file); // Si c'est un fichier local valide
        } else {
          return const AssetImage('assets/images/default.png'); // Image par défaut si le fichier n'existe pas
        }
      }
    } else {
      return const AssetImage('assets/images/default.png'); // Image par défaut si l'URL est vide
    }
  }
}