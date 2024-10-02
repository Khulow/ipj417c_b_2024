import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String email;
  String displayName;
  String profilePictureUrl;
  String role;
  List<String> favoriteListings;
  //preferences
  //recentSEARVCHES

  User({
    required this.userId,
    required this.email,
    this.displayName = '',
    this.profilePictureUrl = '',
    this.role = 'user',
    this.favoriteListings = const [],
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      role: data['role'] ?? 'user',
      favoriteListings: List<String>.from(data['favoriteListings'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'role': role,
      'favoriteListings': favoriteListings,
    };
  }
}
