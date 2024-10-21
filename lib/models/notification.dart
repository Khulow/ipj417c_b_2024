import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  final String id;
  final String userId;
  final String message;
  final String
      type; // e.g., 'listing_approved', 'listing_rejected', 'new_message'
  final String? relatedId; // e.g., listing ID or message ID
  final DateTime createdAt;
  bool isRead;

  UserNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
  });

  factory UserNotification.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      relatedId: data['relatedId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
