import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';

class AdminListingCard extends StatelessWidget {
  final DocumentSnapshot listing;

  const AdminListingCard({required this.listing, super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final listingViewModel =
            Provider.of<ListingViewModel>(context, listen: false);

        return Card(
          child: ListTile(
            title: Text(listing['title']),
            subtitle: Text(listing['description']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _handleStatusUpdate(
                      context, listingViewModel, 'approved'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _handleStatusUpdate(
                      context, listingViewModel, 'rejected'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStatusUpdate(BuildContext context,
      ListingViewModel listingViewModel, String newStatus) async {
    try {
      await listingViewModel.updateListingStatus(listing.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Listing ${newStatus.capitalize()}')),
        );
      }
      print('Listing ${listing.id} status updated to $newStatus');
    } catch (e) {
      print('Error updating listing status: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update listing status')),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
