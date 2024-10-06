import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListingDetailView extends StatelessWidget {
  final QueryDocumentSnapshot listing;

  const ListingDetailView({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = listing.data() as Map<String, dynamic>;
    String status = data['status'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? 'Listing Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['images'] != null && (data['images'] as List).isNotEmpty)
              Image.network(data['images'][0],
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price: \$${data['price']}',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'pending'
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(data['description'] ?? 'No description available'),
                  SizedBox(height: 16),
                  Text('Address: ${data['address']}'),
                  Text('Neighborhood: ${data['neighborhood']}'),
                  Text(
                      'Distance from Campus: ${data['distanceFromCampus']} km'),
                  SizedBox(height: 16),
                  Text('Amenities:',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...(data['amenities'] as List<dynamic>? ?? [])
                      .map((amenity) => Text('• $amenity'))
                      .toList(),
                  SizedBox(height: 16),
                  Text('Safety Features:',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...(data['safetyFeatures'] as Map<String, dynamic>? ?? {})
                      .entries
                      .where((entry) => entry.value == true)
                      .map((entry) => Text('• ${entry.key}'))
                      .toList(),
                  SizedBox(height: 16),
                  Text('House Rules:',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...(data['rules'] as List<dynamic>? ?? [])
                      .map((rule) => Text('• $rule'))
                      .toList(),
                  SizedBox(height: 8),
                  if (data['isBursaryEligible'] == true)
                    Text('This listing is bursary eligible',
                        style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
