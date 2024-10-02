/* import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _error = null;
      notifyListeners();
    });
  }

  Future<bool> registerUser(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'user',
        'favoriteListings': [],
      });

      await userCredential.user!.updateDisplayName(displayName);
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
 */