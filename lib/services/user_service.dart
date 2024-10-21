import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getUserData(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.exists ? User.fromFirestore(doc) : null;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).update(data);
  }

  Future<void> createUser(String userId, Map<String, dynamic> userData) {
    return _firestore.collection('users').doc(userId).set(userData);
  }

  Future<void> toggleFavorite(String userId, String listingId) {
    return _firestore.collection('users').doc(userId).update({
      'favoriteListings': FieldValue.arrayUnion([listingId])
    });
  }

  Future<void> notifyUserAboutListing(
      String userId, String listingId, String status) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'listingId': listingId,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
