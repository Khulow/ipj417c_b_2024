import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/views/admin/widgets/admin_listing%20card.dart';
import 'package:ipj417c_b_2024/views/auth/login_screen.dart';
import 'package:provider/provider.dart';

class AdminListingsView extends StatelessWidget {
  const AdminListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ListingViewModel(Provider.of<UserViewModel>(context, listen: false)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin: Pending Listings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final userViewModel =
                    Provider.of<UserViewModel>(context, listen: false);
                await userViewModel.logoutUser();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        body: Consumer<ListingViewModel>(
          builder: (context, listingViewModel, child) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final listings = snapshot.data?.docs ?? [];

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
            );
          },
        ),
      ),
    );
  }
}
