import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestProvider with ChangeNotifier {
  final ref = FirebaseFirestore.instance.collection('rides');
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> acceptRequest(String rideId) async {
    await ref.doc(rideId).update({
      'status': 'accepted',
      'riderId': uid,
    });
    notifyListeners();
  }

  Future<void> arrivedAtPickup(String rideId) async {
    await ref.doc(rideId).update({
      'status': 'arrived',
    });
    notifyListeners();
  }

  Future<void> startRide(String rideId) async {
    await ref.doc(rideId).update({
      'status': 'ongoing',
    });
    notifyListeners();
  }

  Future<void> cancelRide(RequestModel request) async {
    await ref.doc(request.id).update({
      'status': 'cancelled',
    });
    await FirebaseFirestore.instance
        .collection('riders')
        .doc(uid)
        .update({'rideId': ''});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(request.user!.userId)
        .update({'rideId': ''});
    notifyListeners();
  }

  Future<void> endRide(String rideId) async {
    await ref.doc(rideId).update({
      'status': 'completed',
    });
    await FirebaseFirestore.instance
        .collection('riders')
        .doc(uid)
        .update({'rideId': ''});
    notifyListeners();
  }

  Future<void> paymentReceived(String rideId, String userId) async {
    await ref.doc(rideId).update({
      'status': 'paid',
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'rideId': ''});
    notifyListeners();
  }

  Future<RequestModel> getRequestedRide(String id) async {
    final doc = await ref.doc(id).get();
    return RequestModel.fromJson(doc.data()!);
  }
}
