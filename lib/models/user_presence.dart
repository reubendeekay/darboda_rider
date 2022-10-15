import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class UserPresence {
  static rtdbAndLocalFsPresence() async {
    // All the refs required for updating
    var uid = FirebaseAuth.instance.currentUser!.uid;

    final db = FirebaseDatabase.instance.ref('users').child(uid);

    var riderFirestoreRef =
        FirebaseFirestore.instance.collection('riders').doc(uid);

    var isOfflineForDatabase = {
      "isOnline": false,
      "lastSeen": ServerValue.timestamp,
    };

    var isOnlineForDatabase = {
      "isOnline": true,
      "lastSeen": ServerValue.timestamp,
    };

    // Firestore uses a different server timestamp value, so we'll
    // create two more constants for Firestore state.
    var isOfflineForFirestore = {
      "isOnline": false,
      "lastSeen": FieldValue.serverTimestamp(),
    };

    var isOnlineForFirestore = {
      "isOnline": true,
      "lastSeen": FieldValue.serverTimestamp(),
    };

    FirebaseDatabase.instance
        .ref()
        .child('.info/connected')
        .onValue
        .listen((event) async {
      if (event.snapshot.value == false) {
        // Instead of simply returning, we'll also set Firestore's state
        // to 'offline'. This ensures that our Firestore cache is aware
        // of the switch to 'offline.'
        riderFirestoreRef.update(isOfflineForFirestore);
        return;
      }

      await db.onDisconnect().update(isOfflineForDatabase).then((snap) {
        db.set(isOnlineForDatabase);

        // We'll also add Firestore set here for when we come online.
        riderFirestoreRef.update(isOnlineForFirestore);
      });
    });
  }
}
