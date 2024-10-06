import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/views/listing_view_detail.dart';

class ListingCard extends StatelessWidget {
  final QueryDocumentSnapshot listing;

  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    var data = listing.data() as Map<String, dynamic>;
    String status = data['status'] ?? 'Unknown';

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(data['title'] ?? 'No Title'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${data['price'] ?? 'N/A'} - ${data['neighborhood'] ?? 'N/A'}'),
            SizedBox(height: 4),
            Text(
              'Status: $status',
              style: TextStyle(
                color: status == 'pending' ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: data['images'] != null && (data['images'] as List).isNotEmpty
            ? Image.network(data['images'][0],
                width: 50, height: 50, fit: BoxFit.cover)
            : Icon(Icons.home),
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
