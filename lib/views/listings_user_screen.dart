import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/views/add_listings.dart';
import 'package:ipj417c_b_2024/common_widgets/ListingCard.dart';

import 'package:provider/provider.dart';

class ListingsUserScreen extends StatelessWidget {
  const ListingsUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userViewModel.error != null) {
            return Center(child: Text('Error: ${userViewModel.error}'));
          }

          return FutureBuilder<List<Listing>>(
            future: userViewModel.fetchUserListings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No listings available'));
              }

              List<Listing> userListings = snapshot.data!;

              return ListView.builder(
                itemCount: userListings.length,
                itemBuilder: (context, index) {
                  var listing = userListings[index];
                  return ListingUserCard(listing: listing);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListingScreen()),
          );
        },
        tooltip: 'Add New Listing',
        child: const Icon(Icons.add),
      ),
    );
  }
}
