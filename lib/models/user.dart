import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  admin,
}

class User {
  final String userId;
  final String email;
  String displayName;
  String profilePictureUrl;
  UserRole role;
  List<String> favoriteListings;
  List<String> userListings;

  User({
    required this.userId,
    required this.email,
    this.displayName = '',
    this.profilePictureUrl = '',
    this.role = UserRole.user,
    this.favoriteListings = const [],
    this.userListings = const [],
  });

  //user helper function
  static UserRole _getUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      role: _getUserRole(data['role'] ?? 'user'),
      favoriteListings: List<String>.from(data['favoriteListings'] ?? []),
      userListings: List<String>.from(data['userListings'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'role': role.toString().split('.').last, // convert the enum to a string
      'favoriteListings': favoriteListings,
      'userListings': userListings,
    };
  }
}
