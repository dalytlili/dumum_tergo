import 'package:dumum_tergo/viewmodels/seller/AccueilViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class AccuilSellerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accueilViewModel = Provider.of<AccueilViewModel>(context);
    accueilViewModel.fetchToken();

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        automaticallyImplyLeading: false, // Supprimer l'icône de retour
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => accueilViewModel.logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              "Home",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Consumer<AccueilViewModel>(
              builder: (context, viewModel, child) {
                return Text(
                  viewModel.token != null ? "seller_token: ${viewModel.token}" : "Fetching token...",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}