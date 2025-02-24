import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import '../constants/colors.dart';
import '../viewmodels/sign_up_viewmodel.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: const _SignUpScreenContent(),
    );
  }
}

class _SignUpScreenContent extends StatefulWidget {
  const _SignUpScreenContent();

  @override
  State<_SignUpScreenContent> createState() => _SignUpScreenContentState();
}

class _SignUpScreenContentState extends State<_SignUpScreenContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    final maxWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Créez votre compte',
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
                _buildNameField(viewModel),
                const SizedBox(height: 16),
                _buildEmailField(viewModel),
                const SizedBox(height: 16),
                _buildPhoneField(viewModel),
                const SizedBox(height: 16),
                _buildGenderField(viewModel),
                const SizedBox(height: 16),
                _buildPasswordField(viewModel),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(viewModel),
                const SizedBox(height: 16),
                _buildTermsCheckbox(viewModel),
                const SizedBox(height: 24),
                _buildSignUpButton(viewModel),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: maxWidth > 600 ? 16 : 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  'Sign up with Gmail',
                  'assets/images/google_icon.png',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  'Sign up with Facebook',
                  'assets/images/facebook_icon.png',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  'Sign up with Apple',
                  'assets/images/apple_icon.png',
                  onPressed: () {},
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Vous avez déjà un compte ? ',
                        style: TextStyle(
                          fontSize: maxWidth > 600 ? 16 : 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signin'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Déjà inscrit ? Se connecter',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: viewModel.nameController,
      decoration: InputDecoration(
        hintText: 'Nom complet',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre nom';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'E-mail',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Veuillez entrer un email valide';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: viewModel.phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Numéro de téléphone',
        prefixIcon: InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                viewModel.updateCountry(country);
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewModel.selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${viewModel.selectedCountry.phoneCode}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre numéro de téléphone';
        }
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'Veuillez entrer un numéro valide';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField(SignUpViewModel viewModel) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Sélectionnez votre genre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      value: viewModel.selectedGender.isEmpty ? null : viewModel.selectedGender,
      items: const [
        DropdownMenuItem(
          value: 'Homme',
          child: Text('Homme'),
        ),
        DropdownMenuItem(
          value: 'Femme',
          child: Text('Femme'),
        ),
        DropdownMenuItem(
          value: 'Autre',
          child: Text('Autre'),
        ),
      ],
      onChanged: (value) {
        viewModel.updateGender(value ?? '');
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner votre genre';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: !viewModel.isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isPasswordVisible
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un mot de passe';
        }
        if (value.length < 8) {
          return 'Le mot de passe doit contenir au moins 8 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(SignUpViewModel viewModel) {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      obscureText: !viewModel.isConfirmPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Confirmer le mot de passe',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isConfirmPasswordVisible
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez confirmer votre mot de passe';
        }
        if (value != viewModel.passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox(SignUpViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: viewModel.acceptedTerms,
          onChanged: viewModel.toggleTermsAcceptance,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'En vous inscrivant, vous acceptez les '),
                TextSpan(
                  text: 'Conditions d\'utilisation',
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Terms of Service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conditions d\'utilisation à venir'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                ),
                const TextSpan(text: ' et la '),
                TextSpan(
                  text: 'Politique de confidentialité',
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, '/privacy-policy');
                    },
                ),
                const TextSpan(text: ' de CampNow.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(SignUpViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : () => _handleSignUp(viewModel),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'S\'inscrire',
              style: TextStyle(fontSize: 16),
            ),
    );
  }

  void _handleSignUp(SignUpViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.signUp();
      if (success && mounted) {
        // Construct full phone number with country code
        final fullPhoneNumber =
            '+${viewModel.selectedCountry.phoneCode}${viewModel.phoneController.text}';

        Navigator.pushReplacementNamed(
          context,
          '/otp-verification',
          arguments: fullPhoneNumber,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de l\'inscription. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSocialButton(
    String text,
    String iconPath, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white24
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
