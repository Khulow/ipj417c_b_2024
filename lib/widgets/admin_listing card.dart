import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/views/listing_view_detail.dart';

class AdminListingCard extends StatelessWidget {
  final QueryDocumentSnapshot listing;

  const AdminListingCard({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = listing.data() as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(data['title'] ?? 'No Title'),
        subtitle: Text(
            '${data['price'] ?? 'N/A'} - ${data['neighborhood'] ?? 'N/A'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () => _approveListing(context, listing.id),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectListing(context, listing.id),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailView(listing: listing),
            ),
          );
        },
      ),
    );
  }
}

void _approveListing(BuildContext context, String listingId) async {
  try {
    await FirebaseFirestore.instance
        .collection('listings')
        .doc(listingId)
        .update({
      'status': 'approved',
      'lastVerifiedDate': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Listing approved')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error approving listing: $e')));
  }
}

void _rejectListing(BuildContext context, String listingId) async {
  try {
    await FirebaseFirestore.instance
        .collection('listings')
        .doc(listingId)
        .update({
      'status': 'rejected',
      'lastVerifiedDate': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Listing rejected')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error rejecting listing: $e')));
  }
}
