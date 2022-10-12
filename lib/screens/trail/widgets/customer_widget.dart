import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/loading_screen.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/providers/request_provider.dart';
import 'package:darboda_rider/screens/chat/chat_room.dart';
import 'package:darboda_rider/screens/trail/payment_screen.dart';
import 'package:darboda_rider/screens/trail/trail_screen.dart';
import 'package:darboda_rider/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class CustomerWidget extends StatelessWidget {
  const CustomerWidget({super.key, this.data});
  final DocumentSnapshot<Map<String, dynamic>>? data;
  Map<String, dynamic> getButton(BuildContext context) {
    final status = data!.data()!['status'];
    if (status == 'accepted') {
      return {
        'text': 'Arrived',
        'onPressed': () {
          Provider.of<RequestProvider>(context, listen: false)
              .arrivedAtPickup(data!.data()!['id']);
        }
      };
    }

    if (status == 'arrived') {
      return {
        'text': 'Start Trip',
        'onPressed': () {
          Provider.of<RequestProvider>(context, listen: false)
              .startRide(data!.data()!['id']);
        }
      };
    }

    if (status == 'ongoing') {
      return {
        'text': 'Reached Destination',
        'onPressed': () {
          Provider.of<RequestProvider>(context, listen: false)
              .endRide(data!.data()!['id']);
        }
      };
    }

    if (status == 'completed') {
      return {
        'text': 'Ask for Payment',
        'onPressed': () {
          Get.off(() =>
              PaymentScreen(request: RequestModel.fromJson(data!.data()!)));
        }
      };
    }

    return {
      'text': 'Loading...',
      'onTap': () {},
    };
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? Container(
            height: 400,
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  data!.data()!['status'] == 'accepted'
                      ? 'Picking the Customer'
                      : 'Heading to the Destination',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(data!.data()!['user']['profilePic']),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data!.data()!['user']['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'Arriving in 3 min',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        InkWell(
                          onTap: () async {
                            bool? res =
                                await FlutterPhoneDirectCaller.callNumber(
                                    data!.data()!['user']['phoneNumber']!);

                            if (res == false) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Oops could not make phone call'),
                              ));
                            }
                          },
                          child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Iconsax.call5,
                                color: Colors.grey[700],
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(ChatRoom.routeName,
                                arguments: {
                                  'user': data!.data()!['user'],
                                  'chatRoomId': data!.id
                                });
                          },
                          child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Iconsax.sms5,
                                color: Colors.grey[700],
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        showBottomSheet(
                            context: context,
                            builder: (ctx) => cancelDialogWidget(
                                RequestModel.fromJson(data!.data()!), context));
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.list),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Ride options')
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimaryButton(
                      text: getButton(context)['text'],
                      onTap: () async {
                        await getButton(context)['onPressed']();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          );
  }

  Widget cancelDialogWidget(RequestModel request, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 15,
            ),
            const Center(
              child: Text(
                'Picking the Customer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                await Provider.of<RequestProvider>(context, listen: false)
                    .cancelRide(request);
              },
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5)),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[700],
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text('Cancel Ride')
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ])),
    );
  }
}
