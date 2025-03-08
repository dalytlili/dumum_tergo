// views/profile_view.dart
import 'package:dumum_tergo/constants/colors.dart';
import 'package:flutter/material.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/profile_info.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewModel viewModel = ProfileViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileInfo(user: viewModel.user),
            // Ajoutez d'autres widgets ici si nécessaire
          ],
        ),
      ),
    
    );
  }
}