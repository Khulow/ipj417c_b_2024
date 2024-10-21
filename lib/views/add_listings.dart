import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/views/add_listing_helper.dart';

class AddListingScreen extends StatefulWidget {
  final dynamic listing;

  const AddListingScreen({super.key, this.listing});

  @override
  AddListingScreenState createState() => AddListingScreenState();
}

class AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddListingHelper _helper = AddListingHelper();

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
      status: 'pending',
      depositAmount: 0.0,
      distanceToCampus: 0.0,
      nearbyCampusAmenities: [],
      nearbyFacilities: [],
      publicTransportAccess: '',
      reviews: [],
      roomType: '',
      rules: [],
      securityFeatures: [],
      utilitiesIncluded: false,
      amenities: [],
      contactNumber: '',
      furnishing: '',
      isFavorite: false,
      numberOfBathrooms: 0,
      numberOfBedrooms: 0,
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _helper.pickImages();
    setState(() {
      images.addAll(selectedImages);
    });
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
                  onPressed: () => _helper.submitListing(
                      newListing, images, context, _formKey),
                  child: const Text('Submit Listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
