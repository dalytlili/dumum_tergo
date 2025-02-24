import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/viewmodels/theme_viewmodel.dart';
import 'package:dumum_tergo/views/forgot_password_view.dart';
import 'package:dumum_tergo/views/home_view.dart';
import 'package:dumum_tergo/views/onboarding_screens.dart';
import 'package:dumum_tergo/views/otp_verification_screen.dart';
import 'package:dumum_tergo/views/privacy_policy_screen.dart';
import 'package:dumum_tergo/views/sign_in_screen.dart';
import 'package:dumum_tergo/views/splash_screen.dart';
import 'package:dumum_tergo/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/sign_up_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeViewModel()), // Ajoutez ThemeViewModel ici
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
        return MaterialApp(
          title: 'Dumum Tergo',
          debugShowCheckedModeBanner: false,
          themeMode:
              themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.grey[800]),
              titleTextStyle: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
              labelMedium: TextStyle(color: Colors.white),
              labelSmall: TextStyle(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIconColor: Colors.white70,
              suffixIconColor: Colors.white70,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          home: const SplashScreen(),
          initialRoute: '/',
          routes: {
            '/onboarding': (context) => const OnboardingScreens(),
            '/welcome': (context) => const WelcomeScreen(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const HomeView(),
            '/privacy-policy': (context) => const PrivacyPolicyScreen(),
            '/forgot-password': (context) => const ForgotPasswordView(),
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/otp-verification':
                final String fullPhoneNumber = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(
                    fullPhoneNumber: fullPhoneNumber,
                  ),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
