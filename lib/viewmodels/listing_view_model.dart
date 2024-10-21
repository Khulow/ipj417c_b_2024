import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/models/notification.dart';
import 'package:ipj417c_b_2024/models/review.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart'; // Assuming the Listing class is in a file named listing.dart

class ListingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserViewModel _userViewModel;

  ListingViewModel(this._userViewModel);

  List<Listing> _listings = [];
  bool _isLoading = false;
  String? _error;

  List<Listing> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch listings from Firestore
  // If onlyApproved is true, only fetch approved listings
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

  // Add a new listing to Firestore
  // Returns the ID of the new listing
  // The listing status is set to 'pending' by default
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
      rethrow; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Update listing status and create a notification
// The newStatus parameter should be either 'approved' or 'rejected'
// The notification message depends on the new status
  Future<void> updateListingStatus(String listingId, String newStatus) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update({'status': newStatus});

      DocumentSnapshot listingDoc =
          await _firestore.collection('listings').doc(listingId).get();
      if (listingDoc.exists) {
        Listing updatedListing = Listing.fromFirestore(listingDoc);

        // Create a notification for the listing owner
        String message = newStatus == 'approved'
            ? 'Your listing "${updatedListing.title}" has been approved!'
            : 'Your listing "${updatedListing.title}" has been rejected.';

        UserNotification notification = UserNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: updatedListing.ownerId,
          message: message,
          type:
              newStatus == 'approved' ? 'listing_approved' : 'listing_rejected',
          relatedId: listingId,
          createdAt: DateTime.now(),
        );

        // Add the notification
        await _userViewModel.addNotification(notification);
      }

      await fetchListings(onlyApproved: false);
    } catch (e) {
      print('Error updating listing status: $e');
      _error = "Error updating listing status: $e";
      notifyListeners();
    }
  } //end of updateListingStatus

  // Fetch pending listings for the admin
  // This method is only available to admin users
  // It fetches all listings with a status of 'pending'
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
      rethrow; // Re-throw the error so the UI can handle it
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a listing from Firestore
  Future<void> deleteListing(String listingId, String userId) async {
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

  // Get listings by category name (e.g. 'Apartment', 'House')
  List<Listing> getListingsByCategory(String category) {
    return _listings.where((listing) => listing.category == category).toList();
  }

  // Get available listings only (isAvailable = true)
  List<Listing> getAvailableListings() {
    return _listings.where((listing) => listing.isAvailable).toList();
  }

  // Clear error message after displaying it
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get unique categories from the listings list (e.g. 'Apartment', 'House')
  List<String> getUniqueCategories() {
    return _listings.map((listing) => listing.category).toSet().toList();
  }

  // Get listings by user ID (ownerId) from the listings list
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
  } //end of getListingById

  // Add a new review to Firestore for a specific listing ID and user ID
  Future<void> addReview(
      String listingId, String content, double rating, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        listingId: listingId,
        content: content,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reviews').add(review.toMap());
      print('Review added successfully');
    } catch (e) {
      _error = 'Failed to add review: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } //end of addReview

  // Fetch reviews for a specific listing ID from Firestore
  Future<List<Review>> fetchReviews(String listingId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('listingId', isEqualTo: listingId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      _error = 'Failed to fetch reviews: $e';
      notifyListeners();
      return [];
    }
  } //end of fetchReviews

  // Search listings by title, description, and address
  Future<List<Listing>> searchListings({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    query = query.toLowerCase();
    try {
      return listings
          .where((listing) =>
              (listing.title.toLowerCase().contains(query) ||
                  listing.description.toLowerCase().contains(query) ||
                  listing.address.toLowerCase().contains(query)) &&
              (category == null || listing.category == category) &&
              (minPrice == null || listing.price >= minPrice) &&
              (maxPrice == null || listing.price <= maxPrice))
          .toList();
    } catch (e) {
      print('Error searching listings: $e');
      return [];
    }
  }
}
