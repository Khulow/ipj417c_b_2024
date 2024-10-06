import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String listingId;
  final String ownerId;
  String title;
  String description;
  double price;
  String address;
  List<String> images;
  List<String> amenities;
  List<String> rules;
  bool isVerified;
  String status;
  double averageRating;

  Listing({
    required this.listingId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    this.images = const [],
    this.amenities = const [],
    this.rules = const [],
    this.isVerified = false,
    this.status = 'pending',
    this.averageRating = 0.0,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Listing(
      listingId: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      rules: List<String>.from(data['rules'] ?? []),
      isVerified: data['isVerified'] ?? false,
      status: data['status'] ?? 'pending',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'images': images,
      'amenities': amenities,
      'rules': rules,
      'isVerified': isVerified,
      'status': status,
      'averageRating': averageRating,
    };
  }
}
