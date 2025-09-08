import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? userType;

  Future<void> login(String email, String password) async {
    final result =
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    final snapshot =
    await _db.collection('users').doc(result.user!.uid).get();

    userType = snapshot.data()?['role'] ?? 'officer';

    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    userType = null;
    notifyListeners();
  }
}