import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:provider/provider.dart';

class AddListingHelper {
  final ImagePicker _picker = ImagePicker();

  Future<List<XFile>> pickImages() async {
    return await _picker.pickMultiImage();
  }

  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('listing_images/$fileName');

      try {
        UploadTask uploadTask = firebaseStorageRef.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String url = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        print("Error uploading image: $e");
        continue;
      }
    }
    return imageUrls;
  }

  Future<void> submitListing(Listing newListing, List<XFile> images,
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final listingViewModel =
          Provider.of<ListingViewModel>(context, listen: false);

      if (userViewModel.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You must be logged in to create a listing')));
        return;
      }

      if (newListing.title.isEmpty ||
          newListing.description.isEmpty ||
          newListing.price <= 0 ||
          newListing.address.isEmpty ||
          newListing.category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please fill in all required fields')));
        return;
      }

      newListing.ownerId = userViewModel.user!.userId;
      newListing.isAvailable = true;
      newListing.averageRating = 0.0;
      newListing.status = 'pending';

      String? listingId;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        List<String> imageUrls = await uploadImages(images);
        newListing.images = imageUrls;

        listingId = await listingViewModel.addListing(
            newListing, userViewModel.user!.userId);

        await userViewModel.addListingToUser(listingId!);
      } catch (e) {
        print("Error during Firebase operations: $e");
      } finally {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (listingId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing submitted for approval')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Listing created, but there was an error updating the UI')));
      }
    }
  }
}
