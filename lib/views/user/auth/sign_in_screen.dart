import 'package:dumum_tergo/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import '../../../viewmodels/user/SignInViewModel.dart';
import '../../../constants/colors.dart';

final storage = FlutterSecureStorage();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(
        loginService: LoginService(client: http.Client()),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Se connecter'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Consumer<SignInViewModel>(
              builder: (context, viewModel, child) {
                final maxWidth = MediaQuery.of(context).size.width;

                if (viewModel.hasUserInteractedWithToggle) {
                  _animationController.stop();
                }

                return Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connectez-vous avec votre e-mail ou numéro de téléphone',
                        style: TextStyle(
                          fontSize: maxWidth > 600 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (!viewModel.isPhoneMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Cliquez sur l\'icône pour basculer vers la connexion par numéro'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Utiliser le numéro de téléphone?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextFormField(
                        controller: viewModel.emailController,
                        keyboardType: viewModel.isPhoneMode
                            ? TextInputType.phone
                            : TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: viewModel.isPhoneMode
                              ? 'Numéro de téléphone'
                              : 'E-mail',
                          prefixIcon: viewModel.isPhoneMode
                              ? InkWell(
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        viewModel.setSelectedCountry(country);
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(viewModel.selectedCountry.flagEmoji, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 8),
                                        Text('+${viewModel.selectedCountry.phoneCode}', style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey[700],
                                          fontSize: 14,
                                        )),
                                        const SizedBox(width: 8),
                                        Icon(Icons.arrow_drop_down,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.grey[700]),
                                      ],
                                    ),
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                      suffixIcon: Consumer<SignInViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.hasUserInteractedWithToggle) {
      _animationController.stop();
    }

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 0), // ajuste ici le décalage
          child: Transform.translate(
            offset: Offset(0, -_bounceAnimation.value + 10), // +6 pour descendre
            child: Tooltip(
              message: viewModel.isPhoneMode
                  ? 'Basculer vers email'
                  : 'Basculer vers téléphone',
              child: IconButton(
                icon: Icon(
                  viewModel.isPhoneMode ? Icons.email : Icons.phone,
                  size: 24, // tu peux aussi jouer avec la taille
                ),
                onPressed: () {
                  if (!viewModel.hasUserInteractedWithToggle) {
                    viewModel.setUserInteractedWithToggle();
                  }
                  viewModel.togglePhoneMode();
                },
              ),
            ),
          ),
        );
      },
    );
  },
),

                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return viewModel.isPhoneMode
                                ? 'Veuillez entrer votre numéro'
                                : 'Veuillez entrer votre email';
                          }
                          if (viewModel.isPhoneMode) {
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Veuillez entrer un numéro valide';
                            }
                          } else {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Veuillez entrer un email valide';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: viewModel.passwordController,
                        obscureText: !viewModel.isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Entrez votre mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(viewModel.isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: viewModel.rememberMe,
                            onChanged: (value) {
                              viewModel.toggleRememberMe(value ?? false);
                            },
                          ),
                          const Text('Se souvenir de moi'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () => viewModel.loginUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Connexion',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("OU"),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 16),
                 _buildSocialButton(
  'Inscrivez-vous avec Gmail',
  'assets/images/google_icon.png',
onPressed: () async {
    await viewModel.loginWithGoogle(context);
  },),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        'Inscrivez-vous avec Facebook',
                        'assets/images/facebook_icon.png',
                        onPressed: () async {
                              await viewModel.loginWithFacebook(context);

                        },
                      ),
                   
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous n\'avez pas de compte ? ',
                            style: TextStyle(
                              fontSize: maxWidth > 600 ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Créer un compte',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    String iconPath, {
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}