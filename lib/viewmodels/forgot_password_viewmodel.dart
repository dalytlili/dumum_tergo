import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String? errorMessage;
  bool _isLoading = false;
  
  Country selectedCountry = Country(
    phoneCode: "216",
    countryCode: "TN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Tunisia",
    example: "216 00 000 000",
    displayName: "Tunisia",
    displayNameNoCountryCode: "TN",
    e164Key: "",
  );

  TextEditingController phoneNumberController = TextEditingController();
  
  bool get isLoading => _isLoading;

  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      errorMessage = 'Veuillez entrer votre numéro de téléphone.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simuler une vérification
      await Future.delayed(const Duration(seconds: 1));
      
      // Pour test, considérer tous les numéros comme valides
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = "Une erreur s'est produite";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }
}
