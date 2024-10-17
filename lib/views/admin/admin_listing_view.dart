import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/views/admin/widgets/admin_listing%20card.dart';
import 'package:provider/provider.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/views/auth/login_screen.dart';

class AdminListingsView extends StatelessWidget {
  const AdminListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Pending Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Get the UserViewModel
              final userViewModel =
                  Provider.of<UserViewModel>(context, listen: false);

              // Call the logout method
              await userViewModel.logoutUser();

              // Navigate to the login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listings = snapshot.data!.docs;

          if (listings.isEmpty) {
            return const Center(child: Text('No pending listings.'));
          }
          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return AdminListingCard(listing: listings[index]);
            },
          );
        },
      ),
    );
  }
}
