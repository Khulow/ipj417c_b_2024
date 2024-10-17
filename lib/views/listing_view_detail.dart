import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';

class ListingDetailView extends StatelessWidget {
  final Listing listing;

  const ListingDetailView({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    String status = listing.status;

    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.images.isNotEmpty)
              Image.network(listing.images[0],
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price: \$${listing.price}',
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
                  const SizedBox(height: 8),
                  Text(listing.description),
                  const SizedBox(height: 16),
                  Text('Address: ${listing.address}'),
                  //add posted by user display name
                  Text('Posted by: ${listing.ownerId}'),
                  // Add other fields as necessary
                  // Example:
                  // Text('Neighborhood: ${listing.neighborhood}'),
                  // Text('Distance from Campus: ${listing.distanceFromCampus} km'),
                  const SizedBox(height: 16),
                  // Text('Amenities:',
                  //     style: Theme.of(context).textTheme.titleMedium),
                  // ...listing.amenities.map((amenity) => Text('• $amenity')).toList(),
                  // SizedBox(height: 16),
                  // Text('Safety Features:',
                  //     style: Theme.of(context).textTheme.titleMedium),
                  // ...listing.safetyFeatures.entries
                  //     .where((entry) => entry.value == true)
                  //     .map((entry) => Text('• ${entry.key}'))
                  //     .toList(),
                  // SizedBox(height: 16),
                  // Text('House Rules:',
                  //     style: Theme.of(context).textTheme.titleMedium),
                  // ...listing.rules.map((rule) => Text('• $rule')).toList(),
                  // SizedBox(height: 8),
                  // if (listing.isBursaryEligible)
                  //   Text('This listing is bursary eligible',
                  //       style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
