import 'package:ars/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? userType;

  String adminEmail = '';

  Future<void> login(String email, String password) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final result =
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    final snapshot =
    await _db.collection('users').doc(result.user!.uid).get();

    adminEmail = email;

    userType = snapshot.data()?['role'] ?? 'officer';
    sharedPrefs.setString(adminPasswrd, password);

    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    userType = null;
    notifyListeners();
  }
}