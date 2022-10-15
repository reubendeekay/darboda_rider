import 'package:darboda_rider/helpers/distance_helper.dart';
import 'package:darboda_rider/loading_screen.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/providers/request_provider.dart';
import 'package:darboda_rider/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class PaymentInfoWidget extends StatelessWidget {
  const PaymentInfoWidget({super.key, required this.request});
  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(
          height: 15,
        ),
        const Center(
          child: Text(
            'Payment Info',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Text(
                'You can also receive cash payment instead of M-Pesa if both you and the customer are willing to do so.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Text(
                    'Amount to pay',
                  ),
                  const Spacer(),
                  Text(
                    'TZS ${moneyFormat(request.amount!)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: const [
                  Text(
                    'Tip',
                  ),
                  Spacer(),
                  Text(
                    'TZS 0.0',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.black),
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              const SizedBox(
                height: 15,
              ),
              PrimaryButton(
                text: 'Cash Payment Received',
                onTap: () async {
                  await Provider.of<RequestProvider>(context, listen: false)
                      .paymentReceived(request.id!, request.user!.userId!);
                  Get.to(() => const InitialLoadingScreen());
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

  Widget cancelDialogWidget() {
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
            Row(
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
            const SizedBox(
              height: 20,
            ),
          ])),
    );
  }
}
