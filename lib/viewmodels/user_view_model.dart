import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/models/user.dart';

class UserViewModel extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = User.fromFirestore(doc);
      } else {
        _error = "User document does not exist";
      }
    } catch (e) {
      _error = "Error loading user data: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _error = null;
      await loadUserData(_auth.currentUser!.uid);

      // Check if the logged-in user is an admin
      if (_user?.role == UserRole.admin) {
        print('Admin user logged in');
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

  Future<void> logoutUser() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

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
  }

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

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user == null) {
        throw Exception('No user logged in');
      }

      // Create a reference to the location you want to upload to in firebase
      Reference ref =
          _storage.ref().child('profile_pictures/${_user!.userId}.jpg');

      // Upload the file to firebase
      UploadTask uploadTask = ref.putFile(imageFile);

      // Await the completion of the upload task
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
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

  Future<void> addListingToUser(String listingId) async {
    if (_user != null) {
      _user!.userListings.add(listingId);
      await _firestore.collection('users').doc(_user!.userId).update({
        'userListings': FieldValue.arrayUnion([listingId]),
      });
      notifyListeners();
    }
  }

  Future<void> removeListingFromUser(String listingId) async {
    if (_user != null) {
      _user!.userListings.remove(listingId);
      await _firestore.collection('users').doc(_user!.userId).update({
        'userListings': FieldValue.arrayRemove([listingId]),
      });
      notifyListeners();
    }
  }

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

  Future<List<Listing>> fetchUserPendingListings() async {
    if (_user == null) return [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('listings')
          .where('ownerId', isEqualTo: _user!.userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs
          .map((doc) => Listing.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = "Error fetching user pending listings: $e";
      notifyListeners();
      return [];
    }
  }

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
  }

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

  Future<void> markNotificationAsRead(String notificationId) async {
    if (_user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_user!.userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      _error = "Failed to mark notification as read: $e";
      notifyListeners();
    }
  }

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
  }

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
  }
}
