import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipj417c_b_2024/models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch notifications globally by userId
  Future<List<UserNotification>> getNotifications(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('notifications') // Global notifications collection
          .where('userId', isEqualTo: userId) // Filter by userId
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => UserNotification.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }

  // Add a new notification to the global notifications collection
  Future<void> addNotification(UserNotification notification) async {
    try {
      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception("Error adding notification: $e");
    }
  }

  // Mark a notification as read by updating the global collection
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception("Error marking notification as read: $e");
    }
  }

  // Delete a notification from the global collection
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception("Error deleting notification: $e");
    }
  }
}
