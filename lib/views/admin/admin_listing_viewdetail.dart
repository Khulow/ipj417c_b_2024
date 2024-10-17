import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminListingDetailView extends StatelessWidget {
  final QueryDocumentSnapshot listing;

  AdminListingDetailView({required this.listing});

  @override
  Widget build(BuildContext context) {
    var data = listing.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['title'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(data['description']),
            const SizedBox(height: 16),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['ownerId'])
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = snapshot.data!;
                return Text('Posted by: ${user['ownerId']}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
