import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/views/listing_view_detail.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;

  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(listing.title),
        subtitle: Text('${listing.price} - ${listing.address}'),
        leading: listing.images.isNotEmpty
            ? Image.network(listing.images[0],
                width: 50, height: 50, fit: BoxFit.cover)
            : Icon(Icons.home),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailScreen(listing: listing),
            ),
          );
        },
      ),
    );
  }
}
