import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  AddListingScreenState createState() => AddListingScreenState();
}

class AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late Listing newListing;

  List<XFile> images = [];

  final List<String> categories = [
    'Single',
    'Sharing',
    'Girls only',
    'Boys only',
    'Commune'
  ];

  @override
  void initState() {
    super.initState();
    newListing = Listing(
        id: '',
        ownerId: '',
        title: '',
        description: '',
        price: 0.0,
        address: '',
        category: 'Single',
        isAvailable: true,
        images: [],
        averageRating: 0.0,
        status: 'pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Listing')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => newListing.title = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                  onSaved: (value) => newListing.description = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => double.tryParse(value!) == null
                      ? 'Please enter a valid number'
                      : null,
                  onSaved: (value) => newListing.price = double.parse(value!),
                ),
                DropdownButtonFormField<String>(
                  value: newListing.category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((String category) => DropdownMenuItem(
                          value: category, child: Text(category)))
                      .toList(),
                  onChanged: (String? newValue) =>
                      setState(() => newListing.category = newValue!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an address' : null,
                  onSaved: (value) => newListing.address = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Pick Images'),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: images
                      .map((image) => Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        images.addAll(selectedImages);
      });
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
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
        // If there's an error, we'll skip this image and continue with others
        continue;
      }
    }
    return imageUrls;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final listingViewModel =
          Provider.of<ListingViewModel>(context, listen: false);

      if (userViewModel.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You must be logged in to create a listing')));
        return;
      }

      // Ensure all required fields are set
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
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        // Upload images
        print("Uploading images...");
        List<String> imageUrls = await _uploadImages(images);
        newListing.images = imageUrls;
        print("Images uploaded successfully: ${imageUrls.length} images");

        // Add the listing
        print("Adding listing to Firebase...");
        listingId = await listingViewModel.addListing(
            newListing, userViewModel.user!.userId);
        print("Listing added successfully. ID: $listingId");

        // Associate the listing with the user
        print("Associating listing with user...");
        await userViewModel.addListingToUser(listingId!);
        print("Listing associated with user successfully");

        print("All Firebase operations completed successfully");
      } catch (e) {
        print("Error during Firebase operations: $e");
        // Even if there's an error, we don't return here, as the listing might have been created
      } finally {
        // Hide loading indicator
        Navigator.of(context, rootNavigator: true).pop();
      }

      // UI updates and navigation
      try {
        if (listingId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing submitted for approval')));
          Navigator.pop(context);
        } else {
          throw Exception("Listing ID is null");
        }
      } catch (e) {
        print("Error during UI update: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Listing created, but there was an error updating the UI: $e')));
      }
    }
  }
}
