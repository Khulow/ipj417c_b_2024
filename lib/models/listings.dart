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
  //ADD AVERAGE RATING
  double averageRating;

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
    };
  }

  @override
  String toString() {
    return 'Listing(id: $id, title: $title, price: $price, category: $category, status: $status)';
  }
}
