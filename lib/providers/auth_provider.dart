import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/driver_model.dart';
import 'package:darboda_rider/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  RiderModel? _rider;
  UserModel? get user => _user;
  RiderModel? get rider => _rider;
  Future<void> signUp(UserModel userModel) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    userModel.userId = uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(userModel.toJson());
    notifyListeners();
  }

  Future<void> getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      _user = UserModel.fromJson(value);
      if (_user!.isDriver) {
        await getRider();
      }
    });
    await FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'pushToken': token});
    });
    notifyListeners();
  }

  Future<void> getRider() async {
    await FirebaseFirestore.instance
        .collection('riders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      _rider = RiderModel.fromJson(value);
    });
    notifyListeners();
  }

  Future<void> changeOnlineStatus(bool isOnline) async {
    final ref = FirebaseFirestore.instance.collection('riders');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await ref.doc(uid).update({
      'isOnline': isOnline,
    });

    _rider!.isOnline = isOnline;

    notifyListeners();
  }
}
