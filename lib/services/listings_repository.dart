import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ListingRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> addListing({
    required String title,
    required String description,
    required double price,
    required String address,
    required List<XFile> images,
    required List<String> amenities,
    required List<String> rules,
    required double distanceFromCampus,
    required String neighborhood,
    required bool isBursaryEligible,
    required Map<String, dynamic> safetyFeatures,
  }) async {
    List<String> imageUrls = await _uploadImages(images);

    DocumentReference listingRef = await _firestore.collection('listings').add({
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'images': imageUrls,
      'amenities': amenities,
      'rules': rules,
      'isVerified': false,
      'status': 'pending',
      'averageRating': 0.0,
      'distanceFromCampus': distanceFromCampus,
      'neighborhood': neighborhood,
      'isBursaryEligible': isBursaryEligible,
      'safetyFeatures': safetyFeatures,
      'lastVerifiedDate': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await listingRef.update({'listingId': listingRef.id});
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('listing_images/$fileName');
      await ref.putFile(File(image.path));
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }
}
