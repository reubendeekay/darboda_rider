import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/widgets/swipeable_button.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RiderRequestCard extends StatelessWidget {
  const RiderRequestCard({Key? key, required this.rideId}) : super(key: key);
  final String rideId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(15),
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }

          final data = RequestModel.fromJson(snapshot.data!.data()!);
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: CircleProgressBar(
                          foregroundColor: const Color(0xff099766),
                          backgroundColor: Colors.black12,
                          value: 1,
                          animationDuration: const Duration(seconds: 20),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(data.user!.profilePic!),
                          )),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.user!.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location_cross,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                data.pickupAddress!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.more_vert),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location_tick,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                data.destinationAddress!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SwipeableButton(
                  rideId: rideId,
                )
              ],
            ),
          );
        });
  }
}
