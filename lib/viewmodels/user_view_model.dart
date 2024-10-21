import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/models/notification.dart';
import 'package:ipj417c_b_2024/models/user.dart';
import 'package:ipj417c_b_2024/services/notifications_service.dart';

class UserViewModel extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  List<UserNotification> _notifications = [];

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserNotification> get notifications => _notifications;
  String? get currentUserId => _user?.userId;
  bool get isLoggedIn => _user != null;

  // Constructor to listen to auth state changes
  UserViewModel() {
    _auth.authStateChanges().listen((auth.User? firebaseUser) {
      if (firebaseUser != null) {
        loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = User.fromFirestore(doc);
        await fetchNotifications();
      } else {
        _error = "User document does not exist";
      }
    } catch (e) {
      _error = "Error loading user data: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login user with email and password
  Future<bool> loginUser(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _error = null;
      await loadUserData(_auth.currentUser!.uid);

      // Check if the logged-in user is an admin
      if (_user?.role == UserRole.admin) {
        // You can add any additional admin-specific logic here
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register user with email, password, and display name
  Future<bool> registerUser(
      String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user in Firebase Auth
      auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'profilePictureUrl': '',
        'role': 'user',
        'favoriteListings': [],
      });

      // Update display name in Firebase Auth
      await userCredential.user!.updateDisplayName(displayName);

      // Load user data
      await loadUserData(userCredential.user!.uid);

      return true;
    } catch (e) {
      _error = "Registration failed: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout the current user
  Future<void> logoutUser() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Fetch notifications for the current user from the global notifications collection
  Future<void> fetchNotifications() async {
    if (currentUserId == null) {
      _error = "No user logged in";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications =
          await _notificationService.getNotifications(currentUserId!);
    } catch (e) {
      _error = "Failed to fetch notifications: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new notification to the global collection for the current user
  Future<void> addNotification(UserNotification notification) async {
    if (currentUserId == null) {
      _error = "No user logged in";
      notifyListeners();
      return;
    }

    try {
      await _notificationService.addNotification(notification);
      await fetchNotifications(); // Refresh the notifications list after adding a new one
    } catch (e) {
      _error = "Failed to add notification: $e";
      notifyListeners();
    }
  }

  // Delete a notification for the current user
  Future<void> deleteNotification(String notificationId) async {
    if (currentUserId == null) return;

    try {
      await _notificationService.deleteNotification(notificationId);
      await fetchNotifications(); // Refresh notifications after deleting
    } catch (e) {
      _error = "Failed to delete notification: $e";
      notifyListeners();
    }
  } //end of deleteNotification

  // Mark a notification as read for the current user
// Also refreshes the notifications list
  Future<void> markNotificationAsRead(String notificationId) async {
    if (currentUserId == null) return;

    try {
      await _notificationService.markNotificationAsRead(notificationId);
      await fetchNotifications(); // Refresh notifications after marking one as read
    } catch (e) {
      _error = "Failed to mark notification as read: $e";
      notifyListeners();
    }
  } //end of markNotificationAsRead

  // Update the user's profile with a new display name and/or profile picture
  Future<bool> updateProfile(
      {String? displayName, String? profilePictureUrl}) async {
    if (_user != null) {
      if (displayName != null) _user!.displayName = displayName;
      if (profilePictureUrl != null) {
        _user!.profilePictureUrl = profilePictureUrl;
      }

      await _firestore
          .collection('users')
          .doc(_user!.userId)
          .update(_user!.toMap());
      notifyListeners();
      return true;
    }
    return false;
  }

  // Toggle a listing as a favorite for the current user
  // Adds or removes the listing ID from the user's favoriteListings list
  Future<void> toggleFavorite(String listingId) async {
    if (_user != null) {
      if (_user!.favoriteListings.contains(listingId)) {
        _user!.favoriteListings.remove(listingId);
      } else {
        _user!.favoriteListings.add(listingId);
      }

      await _firestore.collection('users').doc(_user!.userId).update({
        'favoriteListings': _user!.favoriteListings,
      });
      notifyListeners();
    }
  } //end of toggleFavorite

  // Upload a profile picture to Firebase Storage
  // Returns the download URL of the uploaded image
  // Returns null if the upload fails
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user == null) {
        throw Exception('No user logged in');
      }
      Reference ref =
          _storage.ref().child('profile_pictures/${_user!.userId}.jpg');

      // Upload the file to firebase
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      _error = "Failed to upload image: ${e.toString()}";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update the user's profile with a new display name and/or profile picture
  // Returns true if the update is successful
  Future<bool> updateProfileWithImage(
      File? imageFile, String? displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? profilePictureUrl;
      if (imageFile != null) {
        profilePictureUrl = await uploadProfilePicture(imageFile);
        if (profilePictureUrl == null) {
          return false;
        }
      }

      bool result = await updateProfile(
        displayName: displayName,
        profilePictureUrl: profilePictureUrl,
      );

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Add a new listing to Firestore and update the user's profile
// with the new listing reference
// Returns the ID of the new listing
  Future<void> addListingToUser(String listingId) async {
    if (_user != null) {
      _user!.userListings.add(listingId);
      await _firestore.collection('users').doc(_user!.userId).update({
        'userListings': FieldValue.arrayUnion([listingId]),
      });
      notifyListeners();
    }
  } //end of addListingToUser

  // Remove a listing from the user's profile
  // Also deletes the listing from the listings collection
  // and removes it from the local list
  Future<void> removeListingFromUser(String listingId) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.userId).update({
          'userListings': FieldValue.arrayRemove([listingId]),
        });
        await _firestore.collection('listings').doc(listingId).delete();
        _user!.userListings.remove(listingId);
        notifyListeners();
      } catch (e) {
        _error = "Failed to remove listing: $e";
        notifyListeners();
      }
    } else {
      print('No user is logged in.');
      _error = "No user logged in";
      notifyListeners();
    }
  } //end of removeListingFromUser

  // Fetch listings for the current user
  // Returns an empty list if no user is logged in
  Future<List<Listing>> fetchUserListings() async {
    if (_user == null) return [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('listings')
          .where('ownerId', isEqualTo: _user!.userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Listing.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = "Error fetching user listings: $e";
      notifyListeners();
      return [];
    }
  }

  // Update a listing's status
  Future<void> updateListingStatus(String listingId, String newStatus) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update({'status': newStatus});
      notifyListeners();
    } catch (e) {
      _error = "Error updating listing status: $e";
      notifyListeners();
    }
  } //end of updateListingStatus

  // Resubmit a listing by updating its status to 'pending'
  // Also notifies the user about the resubmission
  Future<void> resubmitListing(Listing listing) async {
    if (_user == null) return;

    try {
      // Update the listing status to 'pending'
      listing.status = 'pending';

      // Update the listing in Firestore
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toMap());

      // Notify the user about the resubmission
      await notifyUserAboutListing(listing.id, 'resubmitted');
    } catch (e) {
      _error = "Failed to resubmit listing: $e";
      notifyListeners();
    }
  }

// Fetch unread notifications for the current user
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    if (_user == null) return [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(_user!.userId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _error = "Failed to fetch notifications: $e";
      notifyListeners();
      return [];
    }
  } //end of getUnreadNotifications

  // Notify the user about a listing's status change
  // Adds a new notification to the user's notifications collection
  // with the listing ID and status
  Future<void> notifyUserAboutListing(String listingId, String status) async {
    if (_user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_user!.userId)
          .collection('notifications')
          .add({
        'listingId': listingId,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      _error = "Failed to send notification: $e";
      notifyListeners();
    }
  } //end of notifyUserAboutListing
}
