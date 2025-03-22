import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../constants/colors.dart';

class ProfileInfo extends StatelessWidget {
  final User user;

  ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bio', style: TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Travel | Sport | My car | Daily', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
          SizedBox(height: 16),
          Text('Contact Info', style: TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Email: ${user.email}', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
          SizedBox(height: 8),
          Text('Mobile: ${user.mobileNumber}', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
          SizedBox(height: 8),
          Text('Gender: ${user.gender}', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
          SizedBox(height: 8),
          Text('Address: ${user.address}', style: TextStyle(fontSize: 16, color: AppColors.textLight)),
        ],
      ),
    );
  }
}