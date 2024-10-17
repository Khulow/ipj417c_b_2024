import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/models/listings.dart'; // Assuming the Listing class is in a file named listing.dart

class ListingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Listing> _listings = [];
  bool _isLoading = false;
  String? _error;

  List<Listing> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch listings
  Future<void> fetchListings({bool onlyApproved = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('listings');
      if (onlyApproved) {
        query = query.where('status', isEqualTo: 'approved');
      }
      QuerySnapshot querySnapshot = await query.get();
      _listings =
          querySnapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    } catch (e) {
      _error = "Failed to fetch listings: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a listing
  Future<String> addListing(Listing listing, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      listing.status = 'pending';
      listing.ownerId = userId;

      // First, add the listing to get an ID
      DocumentReference docRef =
          await _firestore.collection('listings').add(listing.toMap());
      String listingId = docRef.id;

      // Update the listing with its ID
      await docRef.update({'id': listingId});

      // Add the listing reference to the user's profile
      await _firestore.collection('users').doc(userId).update({
        'listings': FieldValue.arrayUnion([listingId])
      });

      await fetchListings(onlyApproved: false); // Refresh the list after adding
      return listingId;
    } catch (e) {
      _error = "Failed to add listing: $e";
      throw e; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Update listing status
  Future<void> updateListingStatus(String listingId, String newStatus) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update({'status': newStatus});
      await fetchListings(onlyApproved: false);
    } catch (e) {
      _error = "Error updating listing status: $e";
      notifyListeners();
    }
  }

  // Fetch pending listings
  Future<void> fetchPendingListings() async {
    await fetchListings(onlyApproved: false);
    _listings =
        _listings.where((listing) => listing.status == 'pending').toList();
    notifyListeners();
  }

  // Update a listing
  Future<void> updateListing(Listing listing) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toMap());

      // If the listing was rejected and is being resubmitted, update its status
      if (listing.status == 'rejected') {
        await updateListingStatus(listing.id, 'pending');
      }

      await fetchListings(onlyApproved: false);
    } catch (e) {
      _error = "Failed to update listing: $e";
      throw e; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('listings').doc(listingId).delete();
      await fetchListings(); // Refresh the list after deleting
    } catch (e) {
      _error = "Failed to delete listing: $e";
      notifyListeners();
    }
  }

  // Get listings by category
  List<Listing> getListingsByCategory(String category) {
    return _listings.where((listing) => listing.category == category).toList();
  }

  // Get available listings
  List<Listing> getAvailableListings() {
    return _listings.where((listing) => listing.isAvailable).toList();
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get unique categories
  List<String> getUniqueCategories() {
    return _listings.map((listing) => listing.category).toSet().toList();
  }

  // Get listings by user ID
  List<Listing> getUserListings(String userId) {
    return _listings.where((listing) => listing.ownerId == userId).toList();
  }

  Future<Listing?> getListingById(String listingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return Listing.fromFirestore(doc);
      }
    } catch (e) {
      _error = "Failed to fetch listing: $e";
      notifyListeners();
    }
    return null;
  }
}
