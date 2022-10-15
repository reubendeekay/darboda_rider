import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/screens/history/ride_details_screen.dart';
import 'package:darboda_rider/widgets/loading_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        centerTitle: true,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('rider.userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 200,
                        child: Lottie.asset('assets/empty.json'),
                      ),
                    ),
                    const Text(
                      'No Rides Yet',
                    ),
                  ]);
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final request =
                    RequestModel.fromJson(snapshot.data!.docs[index].data());
                return ListTile(
                  onTap: () {
                    Get.to(() => RideDetailsScreen(request: request));
                  },
                  leading: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Iconsax.map)),
                  title: Text(
                    request.destinationAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    request.pickupAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(request.timestamp!.toDate()),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return LoadingEffect.getSearchLoadingScreen(context);
          }
        },
      ),
    );
  }
}
