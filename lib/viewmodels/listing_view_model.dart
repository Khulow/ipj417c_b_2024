import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:ipj417c_b_2024/models/listings.dart';

class ListingsViewModel extends ChangeNotifier {
  List<Listing> _listings = [];
  List<Listing> get listings => _listings;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchListings() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('listings')
        .where('isVerified', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .get();

    _listings =
        querySnapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    notifyListeners();
  }

  Future<void> addListing(Listing listing) async {
    DocumentReference docRef =
        await _firestore.collection('listings').add(listing.toMap());
    listing.listingId = docRef.id;
    _listings.add(listing);
    notifyListeners();
  }

  Future<void> updateListing(Listing listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.listingId)
        .update(listing.toMap());
    int index = _listings.indexWhere((l) => l.listingId == listing.listingId);
    if (index != -1) {
      _listings[index] = listing;
      notifyListeners();
    }
  }
}
