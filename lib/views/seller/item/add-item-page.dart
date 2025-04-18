import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/views/seller/search-location.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/views/seller/search-location.dart';
import 'package:dumum_tergo/views/user/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart'; // Pour MediaType
import 'package:mime/mime.dart'; // Ajoutez cette importation

class AddCampingItemPage extends StatefulWidget {
  @override
  _AddCampingItemPageState createState() => _AddCampingItemPageState();
}

class _AddCampingItemPageState extends State<AddCampingItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _rentalPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<XFile> _itemImages = [];
  String? selectedCategory;
  String? selectedCondition;
  bool isForSale = false;
  bool isForRent = false;
  int _currentStep = 0;

  final List<String> categories = [
    'Tentes',
    'Sac de couchage',
    'Matelas',
    'Réchaud',
    'Lampe',
    'Cuisine',
    'Autre'
  ];

  final List<String> conditions = [
    'Neuf',
    'Comme neuf',
    'Bon état',
    'État moyen',
    'À réparer'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Ajouter un article de camping'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Indicateur d'étapes
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, 'Infos'),
                SizedBox(width: 16),
                _buildStepIndicator(1, 'Prix'),
                                SizedBox(width: 16),

                _buildStepIndicator(2, 'Photos'),
              ],
            ),
          ),
          
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _continue,
              onStepCancel: _cancel,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, details) {
                return Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (_currentStep != 0)
                        Expanded(
                          child: OutlinedButton(
                               style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 16),

                         // backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            
                          ),
                        ),
                            onPressed: details.onStepCancel,
                            child: Text('Retour'),
                          ),
                        ),
                      if (_currentStep != 0) SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep == 2 ? 'Publier' : 'Continuer'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                // Étape 1: Informations de base
                Step(
                  title: Text('Informations'),
                  content: Column(
                    children: [
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration('Nom de l\'article*'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _buildInputDecoration('Description*'),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: _buildInputDecoration('Catégorie*'),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCondition,
                        decoration: _buildInputDecoration('État*'),
                        items: conditions.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCondition = value;
                          });
                        },
                      ),
                  
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0 
                      ? (_validateStep1() ? StepState.complete : StepState.editing)
                      : StepState.disabled,
                ),

                // Étape 2: Prix et options
                Step(
                  title: Text('Prix et options'),
                  content: Column(
                    children: [
                      SwitchListTile(
                        title: Text('À vendre'),
                        value: isForSale,
                        onChanged: (value) {
                          setState(() {
                            isForSale = value;
                            if (!value && !isForRent) {
                              isForRent = true;
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      if (isForSale) ...[
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Prix de vente (TND)*'),
                        ),
                      ],
                      SwitchListTile(
                        title: Text('À louer'),
                        value: isForRent,
                        onChanged: (value) {
                          setState(() {
                            isForRent = value;
                            if (!value && !isForSale) {
                              isForSale = true;
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      if (isForRent) ...[
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _rentalPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Prix de location (TND/jour)*'),
                        ),
                      ],
                      SizedBox(height: 16),
                      SearchLocationField(controller: _locationController),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep >= 1 
                      ? (_validateStep2() ? StepState.complete : StepState.editing)
                      : StepState.disabled,
                ),

                // Étape 3: Photos
                Step(
                  title: Text('Photos'),
                  content: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Ajouter des photos', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_itemImages.isEmpty)
                        Text('Aucune photo sélectionnée', style: TextStyle(color: Colors.grey)),
                      if (_itemImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _itemImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_itemImages[index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _itemImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep >= 2 
                      ? (_validateStep3() ? StepState.complete : StepState.editing)
                      : StepState.disabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _currentStep >= stepNumber ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (stepNumber + 1).toString(),
              style: TextStyle(
                color: _currentStep >= stepNumber ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: _currentStep >= stepNumber ? AppColors.primary : Colors.grey,
            fontWeight: _currentStep == stepNumber ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _itemImages.addAll(pickedImages);
      });
    }
  }

  bool _validateStep1() {
    return _nameController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           selectedCategory != null &&
           selectedCondition != null;
  }

  bool _validateStep2() {
    bool priceValid = true;
    if (isForSale && _priceController.text.isEmpty) priceValid = false;
    if (isForRent && _rentalPriceController.text.isEmpty) priceValid = false;
    return _locationController.text.isNotEmpty && priceValid;
  }

  bool _validateStep3() {
    return _itemImages.isNotEmpty;
  }

  void _continue() {
    // Valider l'étape actuelle avant de continuer
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _validateStep1();
        break;
      case 1:
        isValid = _validateStep2();
        break;
      case 2:
        isValid = _validateStep3();
        break;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _submitForm();
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

void _submitForm() async {
  // Validation finale
  if (!_validateStep1() || !_validateStep2() || !_validateStep3()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez vérifier toutes les informations')),
    );
    return;
  }

  // Récupérer le token d'authentification
  final token = await storage.read(key: 'seller_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session expirée, veuillez vous reconnecter')),
    );
    return;
  }

  // Préparer la requête multipart
  const url = 'http://localhost:9098/api/camping/items';
  var request = http.MultipartRequest('POST', Uri.parse(url))
    ..headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

  // Ajouter les champs textuels
  request.fields.addAll({
    'name': _nameController.text,
    'description': _descriptionController.text,
    'category': selectedCategory!,
    'condition': selectedCondition!,
    'isForSale': isForSale.toString(),
    'isForRent': isForRent.toString(),
    'location': _locationController.text,
  });

  if (isForSale) {
    request.fields['price'] = _priceController.text;
  }
  if (isForRent) {
    request.fields['rentalPrice'] = _rentalPriceController.text;
  }

  // Ajouter les images
  for (var image in _itemImages) {
    var file = File(image.path);
    var mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
    var fileType = mimeType.split('/');
    
    request.files.add(await http.MultipartFile.fromPath(
      'images', 
      file.path,
      contentType: MediaType(fileType[0], fileType[1]),
    ));
  }

  try {
    // Envoyer la requête
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article publié avec succès!')),
      );
      Navigator.of(context).pop(true); // Retour avec succès
    } else {
      final error = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error['message'] ?? 'Erreur lors de la publication')),
      );
    }
  } on SocketException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pas de connexion internet')),
    );
  } on HttpException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur de serveur')),
    );
  } on FormatException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur de format de données')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur inattendue: ${e.toString()}')),
    );
  }
}
}