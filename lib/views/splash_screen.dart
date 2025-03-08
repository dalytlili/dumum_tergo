import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importez Provider
import '../constants/colors.dart';
import '../viewmodels/SignInViewModel.dart'; // Importez votre ViewModel
import 'onboarding_screens.dart';

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
    _checkAutoLogin(); // Appeler _checkAutoLogin au lieu de _navigateToWelcome
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }
Future<void> _checkAutoLogin() async {
  await Future.delayed(const Duration(seconds: 2)); // Ajoutez un délai de 2 secondes

  final signInViewModel = Provider.of<SignInViewModel>(context, listen: false);
  await signInViewModel.autoLogin(context);

  if (signInViewModel.isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    Navigator.pushReplacementNamed(context, '/onboarding');
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