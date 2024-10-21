import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/models/listings.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a listing to Firestore
  Future<void> addListing(Listing listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toMap());
  }

  // Update a listing's status
  Future<void> updateListingStatus(String listingId, String newStatus) async {
    await _firestore
        .collection('listings')
        .doc(listingId)
        .update({'status': newStatus});
  }

  // Delete a listing from Firestore
  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).delete();
  }

  // Fetch listings for a specific user
  Future<List<Listing>> fetchUserListings(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('listings')
        .where('ownerId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
  }

  // Fetch pending listings for a specific user
  Future<List<Listing>> fetchUserPendingListings(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('listings')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    return querySnapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
  }

  // Resubmit a listing by updating its status to 'pending'
  Future<void> resubmitListing(Listing listing) async {
    listing.status = 'pending';
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .update(listing.toMap());
  }
}
