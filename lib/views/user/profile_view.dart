import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dumum_tergo/constants/colors.dart';
import '../../viewmodels/user/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel()..fetchProfileData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  await viewModel.fetchProfileData();
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildProfileHeader(viewModel),
                      _buildPostGrid(),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(viewModel),
          SizedBox(height: 8),
          _buildProfileName(viewModel),
          SizedBox(height: 8),
          _buildProfileStats(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ProfileViewModel viewModel) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: viewModel.profileImageUrl.isNotEmpty
          ? NetworkImage(viewModel.profileImageUrl)
          : AssetImage('assets/images/images.png') as ImageProvider,
    );
  }

  Widget _buildProfileName(ProfileViewModel viewModel) {
    return Text(
      viewModel.name,
      style: TextStyle(
        fontSize: 24,
        color: AppColors.text,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('Posts', '35'),
        _buildStatColumn('Followers', '1500'),
      ],
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPostGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return _buildPostItem();
        },
      ),
    );
  }

  Widget _buildPostItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
