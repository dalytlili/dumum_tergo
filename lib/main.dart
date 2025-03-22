import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/constants/theme_config.dart';
import 'package:dumum_tergo/services/logout_service.dart';
import 'package:dumum_tergo/viewmodels/ChangePasswordViewModel.dart';
import 'package:dumum_tergo/viewmodels/EditProfileViewModel.dart';
import 'package:dumum_tergo/viewmodels/HomeViewModel.dart';
import 'package:dumum_tergo/viewmodels/SettingsViewModel.dart';
import 'package:dumum_tergo/viewmodels/SideMenuViewModel.dart';
import 'package:dumum_tergo/viewmodels/SignInViewModel.dart';
import 'package:dumum_tergo/viewmodels/forgot_password_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/seller/AccueilViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/CompleteProfileSellerViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/PaymentViewModelV.dart';
import 'package:dumum_tergo/viewmodels/seller/SellerLoginViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/otp_verification_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/theme_viewmodel.dart';
import 'package:dumum_tergo/views/ChangePasswordScreen.dart';
import 'package:dumum_tergo/views/SettingsView.dart';
import 'package:dumum_tergo/views/forgot_password_view.dart';
import 'package:dumum_tergo/views/home_view.dart';
import 'package:dumum_tergo/views/onboarding_screens.dart';
import 'package:dumum_tergo/views/otp_verification_screen.dart';
import 'package:dumum_tergo/views/privacy_policy_screen.dart';
import 'package:dumum_tergo/views/profile_view.dart';
import 'package:dumum_tergo/views/seller/CompleteProfileSellerView.dart';
import 'package:dumum_tergo/views/seller/AccuilSellerScreen.dart';
import 'package:dumum_tergo/views/seller/PaymentView.dart';
import 'package:dumum_tergo/views/seller/Seller_Login.dart';
import 'package:dumum_tergo/views/seller/otp_verification_screen.dart';
import 'package:dumum_tergo/views/sign_in_screen.dart';
import 'package:dumum_tergo/views/splash_screen.dart';
import 'package:dumum_tergo/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/login_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'views/sign_up_screen.dart';
import 'services/route_service.dart'; // Importez le fichier de service de routage

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),
                ChangeNotifierProvider(create: (_) => SellerLoginViewModel()),
        ChangeNotifierProvider(create: (_) => CompleteProfileSellerViewModel()),
ChangeNotifierProvider(create: (_) => PaymentViewModel()), // Le constructeur ne nécessite plus de context

        ChangeNotifierProvider(create: (_) => AccueilViewModel()),
        ChangeNotifierProvider(create: (_) => OtpSellerViewModel(fullPhoneNumber: '')), // Initialisez avec une valeur par défaut


        ChangeNotifierProvider(
          create: (_) => SignInViewModel(
            loginService: LoginService(client: http.Client()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(logoutService: LogoutService()),
        ),
        ChangeNotifierProvider(
  create: (_) => SideMenuViewModel(logoutService: LogoutService()),
  child: HomeView(),
),
ChangeNotifierProvider(
  create: (_) => SettingsViewModel(),
),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return FutureBuilder<String?>(
          future: getInitialRoute(), // Utilisez la fonction importée
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            } else {
              return MaterialApp(
  title: 'Dumum Tergo',
  debugShowCheckedModeBanner: false,
  themeMode: themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  home: const SplashScreen(), // Ensure this is valid
  initialRoute: '/splash', // Ensure this matches a route in the routes map
  routes: {
    '/splash': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreens(),
    '/welcome': (context) => const WelcomeScreen(),
    '/signin': (context) => SignInScreen(),
    '/signup': (context) => SignUpScreen(),
    '/home': (context) => const HomeView(),
    '/privacy-policy': (context) => const PrivacyPolicyScreen(),
    '/forgot-password': (context) => const ForgotPasswordView(),
    '/profile': (context) => ProfileView(),
    '/SettingsView': (context) => SettingsView(),
  '/changePassword': (context) => ChangePasswordScreen(),
    '/signin_seller': (context) => SellerLoginView(),
        '/profile_seller': (context) => CompleteProfileSellerView(),
 '/PaymentView': (context) => PaymentView(),
        '/payment-success': (context) => AccuilSellerScreen(), 
        '/complete_profile': (context) => CompleteProfileSellerView(), 

        // Route pour l'écran de succès
  },
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/otp-verification':
        final String phoneNumber = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: phoneNumber,
          ),
        );
         case '/otp-verification':
        final String phoneNumber = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => OtpVerificationSellerScreen(
            phoneNumber: phoneNumber,
          ),
        );
      default:
        return null;
    }

  },
  
);
            }
          },
        );
      },
    );
  }
}