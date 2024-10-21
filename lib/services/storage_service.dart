import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    Reference ref = _storage.ref().child('profile_pictures/$userId.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<List<String>> uploadListingImages(
      String listingId, List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          _storage.ref().child('listing_images/$listingId/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }
}
