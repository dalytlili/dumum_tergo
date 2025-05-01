import 'package:dumum_tergo/constants/colors.dart';
import 'package:dumum_tergo/constants/theme_config.dart';
import 'package:dumum_tergo/services/api_service.dart';
import 'package:dumum_tergo/services/logout_service.dart';
import 'package:dumum_tergo/services/websocket_serviceNotif.dart';
import 'package:dumum_tergo/viewmodels/seller/CampingItemSEllerViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/ChangePasswordViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/EditProfileViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/HomeViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/SettingsViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/SideMenuViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/SignInViewModel.dart';
import 'package:dumum_tergo/viewmodels/user/camping_items_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/user/forgot_password_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/seller/AccueilViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/CompleteProfileSellerViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/EditProfileSellerViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/PaymentViewModelV.dart';
import 'package:dumum_tergo/viewmodels/seller/SellerLoginViewModel.dart';
import 'package:dumum_tergo/viewmodels/seller/otp_verification_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/theme_viewmodel.dart';
import 'package:dumum_tergo/viewmodels/user/rental_search_viewmodel.dart';
import 'package:dumum_tergo/views/user/item/vendor_shop_screen.dart';
import 'package:dumum_tergo/views/user/car/reservation_page.dart';
import 'package:dumum_tergo/views/user/auth/ChangePasswordScreen.dart';
import 'package:dumum_tergo/views/user/SettingsView.dart';
import 'package:dumum_tergo/views/user/auth/forgot_password_view.dart';
import 'package:dumum_tergo/views/user/home_view.dart';
import 'package:dumum_tergo/views/onboarding_screens.dart';
import 'package:dumum_tergo/views/user/auth/otp_verification_screen.dart';
import 'package:dumum_tergo/views/privacy_policy_screen.dart';
import 'package:dumum_tergo/views/user/auth/profile_view.dart';
import 'package:dumum_tergo/views/seller/auth/CompleteProfileSellerView.dart';
import 'package:dumum_tergo/views/seller/AccuilSellerScreen.dart';
import 'package:dumum_tergo/views/seller/auth/PaymentView.dart';
import 'package:dumum_tergo/views/seller/auth/Seller_Login.dart';
import 'package:dumum_tergo/views/seller/auth/VerificationOtpChangeMobile.dart';
import 'package:dumum_tergo/views/seller/auth/otp_verification_screen.dart';
import 'package:dumum_tergo/views/user/auth/sign_in_screen.dart';
import 'package:dumum_tergo/views/splash_screen.dart';
import 'package:dumum_tergo/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/login_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'views/user/auth/sign_up_screen.dart';
import 'services/route_service.dart'; // Importez le fichier de service de routage
import 'package:dumum_tergo/viewmodels/seller/liste_car_viewmodel.dart';
import 'package:dumum_tergo/views/seller/car/car-reservations-page.dart';
import 'package:dumum_tergo/services/notification_service.dart';
import 'package:dumum_tergo/services/notification_service_user.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 final wsService = WebSocketService();
  final storage = FlutterSecureStorage();

   // Récupération du token d'authentification
  final authToken = await storage.read(key: 'authToken');
  final userId = await storage.read(key: 'userId');
  
  // Initialiser le service de notification
  final notificationService = NotificationService();
  await notificationService.initialize();


  final notificationServiceUser = NotificationServiceuser();
await notificationServiceUser.initialize();


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
        ChangeNotifierProvider(create: (_) => EditProfileSellerViewModel()),
        ChangeNotifierProvider(create: (_) => RentalSearchViewModel()),
        ChangeNotifierProvider(create: (_) => RentalSearchViewModel()),
                ChangeNotifierProvider(create: (_) => ListeCarViewModel()),

        Provider<WebSocketService>.value(value: wsService),
        ChangeNotifierProvider(
          create: (context) => CampingItemsViewModel(
            apiService: ApiService(
              baseUrl: 'http://localhost:9098/api',
              // token: 'your-auth-token-if-needed',
            ),
          ),
        ),
         ChangeNotifierProvider(
          create: (context) => CampingItemsSellerViewModel(
            apiService: ApiService(
              baseUrl: 'http://localhost:9098/api',
              // token: 'your-auth-token-if-needed',
            ),
          ),
        ),
ChangeNotifierProvider(
  create: (_) => RentalSearchViewModel(),
),
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
        ChangeNotifierProvider(create: (_) => ListeCarViewModel()),
      ],
child: MyApp(wsService: wsService, initialAuthToken: authToken, initialUserId: userId),
    ),
  );
}

class MyApp extends StatefulWidget {
  final WebSocketService wsService;
  final String? initialAuthToken;
  final String? initialUserId;

  const MyApp({
    super.key,
    required this.wsService,
    this.initialAuthToken,
    this.initialUserId,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    if (widget.initialUserId != null) {
      await widget.wsService.connect(widget.initialUserId!);
    }
  }
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
     '/vendorShop': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return VendorShopScreen(vendorId: args);
    },
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
       '/Reservation-Page': (context) => ReservationPage(), 

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
        case '/otp-verification-change-mobile':
        final String phoneNumber = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => VerificationOtpChangeMobile(
            fullPhoneNumber: phoneNumber,
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