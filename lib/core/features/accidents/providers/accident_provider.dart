import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AccidentsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> reportAccident({
    required String date,
    required String crashTime,
    required String reportTime,
    required String arrivalTime,
    required String responseTime,
    required String route,
    required String location,
    required int noOfVehicles,
    required String vehicleRegNo,
    required String vehicleCategory,
    required String vehicleMake,
    required String vehicleType,
    required String vehicleColor,
    required String fleetName,
    required String driverName,
    required int noPeopleInvolved,
    required int noInjured,
    required int noNotInjured,
    required int noKilled,
    required String typeOfInjury,
    required String typeOfRtc,
    required String probableCauses,
    required String itemsRecovered,
    required String actionTaken,
    File? photoFile,
  }) async {
    String? photoUrl;
    if (photoFile != null) {
      final ref = _storage.ref('accident_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(photoFile);
      photoUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('accidents').add({
      'date': date,
      'crashTime': crashTime,
      'reportTime': reportTime,
      'arrivalTime': arrivalTime,
      'responseTime': responseTime,
      'route': route,
      'location': location,
      'noOfVehicles': noOfVehicles,
      'vehicleRegNo': vehicleRegNo,
      'vehicleCategory': vehicleCategory,
      'vehicleMake': vehicleMake,
      'vehicleType': vehicleType,
      'vehicleColor': vehicleColor,
      'fleetName': fleetName,
      'driverName': driverName,
      'noPeopleInvolved': noPeopleInvolved,
      'noInjured': noInjured,
      'noNotInjured': noNotInjured,
      'noKilled': noKilled,
      'typeOfInjury': typeOfInjury,
      'typeOfRtc': typeOfRtc,
      'probableCauses': probableCauses,
      'itemsRecovered': itemsRecovered,
      'actionTaken': actionTaken,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}