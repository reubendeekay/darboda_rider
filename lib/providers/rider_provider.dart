import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/driver_model.dart';
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
}
