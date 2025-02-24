import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Country selectedCountry = Country(
    phoneCode: "216",
    countryCode: "TN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Tunisia",
    example: "Tunisia",
    displayName: "Tunisia",
    displayNameNoCountryCode: "TN",
    e164Key: "",
  );

  String selectedGender = '';
  bool acceptedTerms = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  void updateCountry(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  void updateGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  void toggleTermsAcceptance(bool? value) {
    acceptedTerms = value ?? false;
    notifyListeners();
  }

  Future<bool> signUp() async {
    // Validate input
    if (!_validateInputs()) {
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual sign-up logic with backend
      print('Inscription avec :');
      print('Nom: ${nameController.text}');
      print('Email: ${emailController.text}');
      print('Téléphone: +${selectedCountry.phoneCode}${phoneController.text}');
      print('Genre: $selectedGender');
      print('Mot de passe: ${passwordController.text}');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    // Implement comprehensive validation
    if (nameController.text.isEmpty) {
      return false;
    }

    if (emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text)) {
      return false;
    }

    if (phoneController.text.isEmpty ||
        !RegExp(r'^\d+$').hasMatch(phoneController.text)) {
      return false;
    }

    if (selectedGender.isEmpty ||
        !['Homme', 'Femme', 'Autre'].contains(selectedGender)) {
      return false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 8) {
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      return false;
    }

    if (!acceptedTerms) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
