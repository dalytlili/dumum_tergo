import 'package:country_picker/country_picker.dart';
import 'package:dumum_tergo/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dumum_tergo/viewmodels/user/EditProfileViewModel.dart';
import 'dart:io'; // Pour manipuler les fichiers

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditProfileViewModel>(context, listen: true);

 return Padding(
  padding: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width * 0.05, // 10% de la largeur de l'écran
    vertical: 30.0, // Garder le padding vertical fixe
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildProfileImage(viewModel),
      const SizedBox(height: 16),
      TextField(
        controller: viewModel.nameController,
        decoration: const InputDecoration(
          labelText: 'Nom',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      _buildGenderField(viewModel), // Champ de sélection du genre
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down,
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
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
      ElevatedButton(
  onPressed: viewModel.isLoading
      ? null // Désactive le bouton pendant le chargement
      : () async {
          await viewModel.updateProfile(context);
        },
  child: viewModel.isLoading
      ? const CircularProgressIndicator() // Affiche un indicateur de chargement
      : const Text('Enregistrer'),
),
    ],
  ),
);

  }

  // Widget pour sélectionner le genre
  Widget _buildGenderField(EditProfileViewModel viewModel) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Sélectionnez votre genre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      value: viewModel.selectedGender.isEmpty ? null : viewModel.selectedGender,
      items: const [
        DropdownMenuItem(
          value: 'Homme',
          child: Text('Homme'),
        ),
        DropdownMenuItem(
          value: 'Femme',
          child: Text('Femme'),
        ),
        DropdownMenuItem(
          value: 'Autre',
          child: Text('Autre'),
        ),
      ],
      onChanged: (value) {
        viewModel.updateGender(value ?? '');
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner votre genre';
        }
        return null;
      },
    );
  }

  // Widget pour afficher et modifier l'image de profil
  Widget _buildProfileImage(EditProfileViewModel viewModel) {
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