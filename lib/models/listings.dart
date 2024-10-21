import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String id;
  String ownerId;
  String title;
  String description;
  double price;
  String address;
  List<String> images;
  bool isAvailable;
  String category;
  String status;
  double averageRating;
  bool isFavorite;
  List<String> amenities;
  List<String> nearbyFacilities;
  double distanceToCampus;
  String roomType;
  bool utilitiesIncluded;
  String leaseDuration;
  String contactNumber;
  List<String> rules;
  String furnishing;
  int numberOfBedrooms;
  int numberOfBathrooms;
  List<Map<String, dynamic>> reviews;
  String publicTransportAccess;
  List<String> securityFeatures;
  double depositAmount;
  List<String> nearbyCampusAmenities;

  Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    this.images = const [],
    this.isAvailable = true,
    this.category = '',
    this.averageRating = 0,
    this.status = 'Pending',
    this.isFavorite = false,
    this.amenities = const [],
    this.nearbyFacilities = const [],
    this.distanceToCampus = 0,
    this.roomType = '',
    this.utilitiesIncluded = false,
    this.leaseDuration = '',
    this.contactNumber = '',
    this.rules = const [],
    this.furnishing = '',
    this.numberOfBedrooms = 0,
    this.numberOfBathrooms = 0,
    this.reviews = const [],
    this.publicTransportAccess = '',
    this.securityFeatures = const [],
    this.depositAmount = 0,
    this.nearbyCampusAmenities = const [],
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      category: data['category'] ?? '',
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      isFavorite: data['isFavorite'] ?? false,
      amenities: List<String>.from(data['amenities'] ?? []),
      nearbyFacilities: List<String>.from(data['nearbyFacilities'] ?? []),
      distanceToCampus: (data['distanceToCampus'] ?? 0).toDouble(),
      roomType: data['roomType'] ?? '',
      utilitiesIncluded: data['utilitiesIncluded'] ?? false,
      leaseDuration: data['leaseDuration'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      rules: List<String>.from(data['rules'] ?? []),
      furnishing: data['furnishing'] ?? '',
      numberOfBedrooms: data['numberOfBedrooms'] ?? 0,
      numberOfBathrooms: data['numberOfBathrooms'] ?? 0,
      reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
      publicTransportAccess: data['publicTransportAccess'] ?? '',
      securityFeatures: List<String>.from(data['securityFeatures'] ?? []),
      depositAmount: (data['depositAmount'] ?? 0).toDouble(),
      nearbyCampusAmenities:
          List<String>.from(data['nearbyCampusAmenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'images': images,
      'isAvailable': isAvailable,
      'category': category,
      'averageRating': averageRating,
      'status': status,
      'isFavorite': isFavorite,
      'amenities': amenities,
      'nearbyFacilities': nearbyFacilities,
      'distanceToCampus': distanceToCampus,
      'roomType': roomType,
      'utilitiesIncluded': utilitiesIncluded,
      'leaseDuration': leaseDuration,
      'contactNumber': contactNumber,
      'rules': rules,
      'furnishing': furnishing,
      'numberOfBedrooms': numberOfBedrooms,
      'numberOfBathrooms': numberOfBathrooms,
      'reviews': reviews,
      'publicTransportAccess': publicTransportAccess,
      'securityFeatures': securityFeatures,
      'depositAmount': depositAmount,
      'nearbyCampusAmenities': nearbyCampusAmenities,
    };
  }

  @override
  String toString() {
    return 'Listing(id: $id, title: $title, price: $price, category: $category, status: $status, isAvailable: $isAvailable, isFavorite: $isFavorite, amenities: $amenities, nearbyFacilities: $nearbyFacilities, distanceToCampus: $distanceToCampus, roomType: $roomType, utilitiesIncluded: $utilitiesIncluded, leaseDuration: $leaseDuration, contactNumber: $contactNumber, rules: $rules, furnishing: $furnishing, numberOfBedrooms: $numberOfBedrooms, numberOfBathrooms: $numberOfBathrooms, reviews: $reviews, publicTransportAccess: $publicTransportAccess, securityFeatures: $securityFeatures, depositAmount: $depositAmount, nearbyCampusAmenities: $nearbyCampusAmenities)';
  }
}
