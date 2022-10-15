import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/loading_screen.dart';
import 'package:darboda_rider/models/user_data_model.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/providers/rider_provider.dart';
import 'package:darboda_rider/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeeklyPaymentScreen extends StatelessWidget {
  const WeeklyPaymentScreen({Key? key, this.isDisabled = false})
      : super(key: key);
  final bool isDisabled;
  String getSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String getNextWeekDate(DateTime nextWeek) {
    int dayNum = nextWeek.day;

    return '${DateFormat('dd').format(nextWeek)}${getSuffix(dayNum)}, ${DateFormat('MMMM').format(nextWeek)}';
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    return WillPopScope(
      onWillPop: () async => !isDisabled,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment and Billing'),
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TZS ${userData.pendingAmount}',
                        style: const TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 2.5,
                      ),
                      Text(
                          'Payment scheduled for ${getNextWeekDate(userData.nextPaymentDate!)}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white,
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('userData')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('payment')
                          .where('isPending', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return ListView(children: [
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'History',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (snapshot.hasData)
                            ...List.generate(
                              snapshot.data!.docs.length,
                              (index) {
                                final data = UserDataModel.fromJson(
                                    snapshot.data!.docs[index].data());
                                return ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Text(DateFormat('dd MMMM')
                                      .format(data.nextPaymentDate!)),
                                  subtitle: Text(
                                      'Earnings - TZS ${data.totalAmount}'),
                                  trailing: Text('- TZS ${data.pendingAmount}'),
                                );
                              },
                            ),
                        ]);
                      }),
                ))
              ],
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: PrimaryButton(
                text: 'Make payment',
                onTap: () async {
                  await Provider.of<RiderProvider>(context, listen: false)
                      .payDueAmount(userData);

                  Get.off(() => const InitialLoadingScreen());
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
