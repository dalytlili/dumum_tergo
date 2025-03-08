// widgets/profile_info.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';

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
          Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('Mobile: ${user.mobileNumber}', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('Gender: ${user.gender}', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('Address: ${user.address}', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}