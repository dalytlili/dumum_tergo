import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../services/login_service.dart';
import 'package:country_picker/country_picker.dart';

class SignInViewModel with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _hasUserInteractedWithToggle = false;
  bool get hasUserInteractedWithToggle => _hasUserInteractedWithToggle;
  bool _isLoggedIn = false; // Propriété privée pour suivre l'état de connexion
  bool get isLoggedIn => _isLoggedIn; 
  Country _selectedCountry = Country(
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
  bool _isPhoneMode = false;
  bool _isLoading = false;
  String _errorMessage = '';
    bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  final FlutterSecureStorage storage = FlutterSecureStorage(); // Instance unique

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isPasswordVisible => _isPasswordVisible;
  Country get selectedCountry => _selectedCountry;
  bool get isPhoneMode => _isPhoneMode;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }
    void setUserInteractedWithToggle() {
    _hasUserInteractedWithToggle = true;
    notifyListeners();
  }
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void togglePhoneMode() {
    _isPhoneMode = !_isPhoneMode;
    _emailController.clear();
    notifyListeners();
  }

  void setSelectedCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  final LoginService loginService;

  SignInViewModel({required this.loginService});

  
 Future<void> autoLogin(BuildContext context) async {
    final email = await storage.read(key: 'email');
    final password = await storage.read(key: 'password');

    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      await loginUser(context);
      _isLoggedIn = true; // Mettre à jour l'état de connexion
    } else {
      _isLoggedIn = false; // L'utilisateur n'est pas connecté
    }
    notifyListeners();
  }




  Future<void> loginWithGoogle(BuildContext context) async {
    final url = 'https://dumum-tergo-backend.onrender.com/auth/google';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'dumumtergo',
      );

      final uri = Uri.parse(result);
      print('URL de retour: $uri'); // Affichez l'URL de retour pour vérification

      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken != null && refreshToken != null) {
        // Enregistrer les tokens dans FlutterSecureStorage
        await storage.write(key: 'token', value: accessToken); // Clé 'token'
        await storage.write(key: 'refreshToken', value: refreshToken);

        print('Tokens enregistrés avec succès');
        print('Access Token: $accessToken');
        print('Refresh Token: $refreshToken');

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion avec Google réussie')),
        );

        // Naviguer vers la page d'accueil
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Tokens non reçus');
      }
    } catch (e) {
      print("Erreur lors de la connexion avec Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion avec Google: $e'),
          backgroundColor: Colors.red,),
        
      );
    }
  }


 Future<void> loginWithFacebook(BuildContext context) async {
    final url = 'https://dumum-tergo-backend.onrender.com/auth/facebook/callback';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: 'dumumtergo',
      );

      final uri = Uri.parse(result);
      print('URL de retour: $uri'); // Affichez l'URL de retour pour vérification

      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken != null && refreshToken != null) {
        // Enregistrer les tokens dans FlutterSecureStorage
        await storage.write(key: 'token', value: accessToken); // Clé 'token'
        await storage.write(key: 'refreshToken', value: refreshToken);

        print('Tokens enregistrés avec succès');
        print('Access Token: $accessToken');
        print('Refresh Token: $refreshToken');

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion avec Facebook réussie')),
        );

        // Naviguer vers la page d'accueil
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Tokens non reçus');
      }
    } catch (e) {
      print("Erreur lors de la connexion avec Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion avec Google: $e'),
          backgroundColor: Colors.red,),
      );
    }
  }


Future<void> loginUser(BuildContext context) async {
  if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
    return;
  }

  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez remplir tous les champs'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  _isLoading = true;
  _errorMessage = '';
  notifyListeners();

  try {
    final countryCode = _isPhoneMode ? _selectedCountry.phoneCode : null;
    if (_isPhoneMode && countryCode == null) {
      throw Exception('Code pays non sélectionné');
    }

    final response = await loginService.authenticate(
      _emailController.text,
      _passwordController.text,
      _isPhoneMode,
      countryCode,
    );

    final accessToken = response['accessToken'];
    final refreshToken = response['refreshToken'];
    final userData = response['user']; // Récupérer les données utilisateur

    if (accessToken != null && userData != null) {
      // Stocker les tokens
      await storage.write(key: 'token', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);

      // Stocker les informations utilisateur
      await _storeUserData(userData);

      if (_rememberMe) {
        await storage.write(key: 'email', value: _emailController.text);
        await storage.write(key: 'password', value: _passwordController.text);
      } else {
        await storage.delete(key: 'email');
        await storage.delete(key: 'password');
      }

      _isLoggedIn = true;
      notifyListeners();
        print('Refresh Token: $userData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  } on Exception catch (e) {
    _errorMessage = e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<void> _storeUserData(Map<String, dynamic> userData) async {
  await storage.write(key: 'userId', value: userData['_id']);
  await storage.write(key: 'userName', value: userData['name']);
  await storage.write(key: 'userEmail', value: userData['email']);
  await storage.write(key: 'userMobile', value: userData['mobile']);
  await storage.write(key: 'userImage', value: userData['image']);
  await storage.write(key: 'userGenre', value: userData['genre']);
  await storage.write(key: 'userRole', value: userData['role']);
  await storage.write(key: 'isVerified', value: userData['is_verified'].toString());
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}