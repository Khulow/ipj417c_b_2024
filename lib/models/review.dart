import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String listingId;
  final String content;
  final double rating; // Assuming you have a rating system
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'],
      listingId: data['listingId'],
      content: data['content'],
      rating: data['rating'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'listingId': listingId,
      'content': content,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
