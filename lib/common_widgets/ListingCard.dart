import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/views/listing_view_detail.dart';

class ListingUserCard extends StatelessWidget {
  final Listing listing;

  const ListingUserCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    String status = listing.status;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(listing.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${listing.price} - ${listing.address}'),
            const SizedBox(height: 4),
            Text(
              'Status: $status',
              style: TextStyle(
                color: status == 'pending' ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: listing.images.isNotEmpty
            ? Image.network(listing.images[0],
                width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.home),
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
