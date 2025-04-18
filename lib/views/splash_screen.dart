import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart'; // Importez Provider
import '../constants/colors.dart';
import '../viewmodels/user/SignInViewModel.dart'; // Importez votre ViewModel
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _controller.forward();
   // _checkAutoLogin();
  _checkAutoLogin(context); // Appeler _checkAutoLoginSeller
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

    final FlutterSecureStorage storage = const FlutterSecureStorage();
Future<void> _checkAutoLogin(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2)); // Délai d'affichage du SplashScreen

  String? userToken = await storage.read(key: 'token'); // Token utilisateur
  String? sellerToken = await storage.read(key: 'seller_token'); // Token vendeur
  String? businessName = await storage.read(key: 'businessName'); // Nom de l'entreprise du vendeur

  if (sellerToken != null ) {
    // Vérifier l'état du compte vendeur
    Navigator.pushReplacementNamed(context, '/payment-success');
    final sellerStatus = await _checkSellerStatus(sellerToken);

    if (sellerStatus['profileCompleted'] == false) {
      // Rediriger vers la page de complétion du profil
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    if (sellerStatus['subscriptionStatus'] == 'active') {
      Navigator.pushReplacementNamed(context, '/payment-success'); // Redirection vendeur actif
      return;
    } else {
      // Si le statut n'est pas "active", rediriger vers une page d'activation
      Navigator.pushReplacementNamed(context, '/PaymentView');
      return;
    }
  }

  if (userToken != null) {
    // Si le token utilisateur existe, vérifier l'authentification utilisateur
    final signInViewModel = Provider.of<SignInViewModel>(context, listen: false);
    await signInViewModel.autoLogin(context);

    if (signInViewModel.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home'); // Redirection client
      return;
    }
  }

  // Si aucun token n'existe ou si l'authentification échoue, rediriger vers Onboarding
  Navigator.pushReplacementNamed(context, '/onboarding');
}

Future<Map<String, dynamic>> _checkSellerStatus(String token) async {
  final uri = Uri.parse('http://127.0.0.1:9098/api/vendor/profile');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> vendorData = responseData['data'];

      // Vérifier si le profil est complété
      final bool profileCompleted = vendorData['profileCompleted'] ?? false;

      // Vérifier le statut de l'abonnement
      final String subscriptionStatus = vendorData['subscription']?['status'] ?? 'inactive';

      return {
        'profileCompleted': profileCompleted,
        'subscriptionStatus': subscriptionStatus,
      };
    }

    return {
      'profileCompleted': false,
      'subscriptionStatus': 'inactive',
    };
  } catch (e) {
    debugPrint('Erreur lors de la vérification du statut du vendeur: $e');
    return {
      'profileCompleted': false,
      'subscriptionStatus': 'inactive',
    };
  }
}


  Widget _buildDot(int index) {
    final double opacity =
        (index - (_fadeController.value * 3)).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 400,
                      height: 400,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                      _buildDot(2),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}