import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/views/admin/admin_listing_viewdetail.dart';

class AdminListingCard extends StatelessWidget {
  final QueryDocumentSnapshot listing;

  const AdminListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    var data = listing.data() as Map<String, dynamic>;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(data['ownerId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              title: Text('Loading...'),
              trailing: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              title: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final user = snapshot.data!;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(data['title'] ?? 'No Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${data['price'] ?? 'N/A'} - ${data['neighborhood'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                // Text('Posted by: ${user['Username'] ?? 'Unknown User'}'),
                Text('Status: ${data['status'] ?? 'pending'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      _updateListingStatus(context, listing.id, 'approved'),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () =>
                      _updateListingStatus(context, listing.id, 'rejected'),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminListingDetailView(listing: listing),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _updateListingStatus(
      BuildContext context, String listingId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Listing ${status == 'approved' ? 'approved' : 'rejected'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating listing: $e')),
      );
    }
  }
}
