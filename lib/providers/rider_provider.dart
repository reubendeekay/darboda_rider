import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/driver_model.dart';
import 'package:darboda_rider/models/user_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class RiderProvider with ChangeNotifier {
  final ref = FirebaseFirestore.instance.collection('riders');
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> registerDriver(RiderModel rider, List<File> files) async {
    List<String> documentUrls = [];
    for (File file in files) {
      final upload = await FirebaseStorage.instance
          .ref('riders/$uid/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(file);
      final url = await upload.ref.getDownloadURL();

      documentUrls.add(url);
    }
    rider.documents = documentUrls;
    await ref.doc(uid).set(rider.toJson());
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isDriver': true,
    });

    final userData = UserDataModel(
      isPending: false,
      nextPaymentDate: DateTime.now().add(Duration(days: 7)),
      pendingAmount: '0.00',
      totalAmount: '0.00',
    );

    await FirebaseFirestore.instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('payment')
        .doc('billing')
        .set(userData.toJson());
    notifyListeners();
  }

  Future<void> editDriverDetails(RiderModel rider, List<File> files) async {
    List<String> documentUrls = [];

    for (File file in files) {
      final upload = await FirebaseStorage.instance
          .ref('riders/$uid/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(file);
      final url = await upload.ref.getDownloadURL();

      documentUrls.add(url);
    }

    if (documentUrls.isNotEmpty) {
      rider.documents = documentUrls;
    }

    await ref.doc(uid).set(rider.toJson());
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isDriver': true,
    });
    notifyListeners();
  }

  Future<void> payDueAmount(UserDataModel userDataModel) async {
    final userDataRef =
        FirebaseFirestore.instance.collection('userData').doc(uid);

    await userDataRef.collection('payment').add(userDataModel.toJson());
    await userDataRef.collection('payment').doc('billing').update({
      'isPending': false,
      'pendingAmount': "0.0",
      'nextPaymentDate': DateTime.now().add(const Duration(days: 7)),
    });
    notifyListeners();
  }
}
