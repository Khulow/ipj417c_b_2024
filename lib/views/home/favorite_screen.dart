import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:provider/provider.dart';
import 'package:ipj417c_b_2024/common_widgets/listing_card.dart'; // Assuming you have a ListingCard widget

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer2<UserViewModel, ListingViewModel>(
        builder: (context, userViewModel, listingViewModel, child) {
          if (userViewModel.isLoading || listingViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userViewModel.error != null) {
            return Center(child: Text('Error: ${userViewModel.error}'));
          }
          if (listingViewModel.error != null) {
            return Center(child: Text('Error: ${listingViewModel.error}'));
          }

          final favoriteListings = userViewModel.user?.favoriteListings ?? [];
          if (favoriteListings.isEmpty) {
            return const Center(child: Text('No favorite listings'));
          }

          return ListView.builder(
            itemCount: favoriteListings.length,
            itemBuilder: (context, index) {
              final listingId = favoriteListings[index];
              final listing = listingViewModel.getListingByIdSync(listingId);

              if (listing == null) {
                return const SizedBox.shrink();
              }

              return ListingCard(listing: listing);
            },
          );
        },
      ),
    );
  }
}

extension ListingViewModelExtensions on ListingViewModel {
  Listing? getListingByIdSync(String listingId) {
    try {
      return listings.firstWhere((listing) => listing.id == listingId);
    } catch (e) {
      return null;
    }
  }
}
