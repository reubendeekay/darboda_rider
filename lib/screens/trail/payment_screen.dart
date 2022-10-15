import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/helpers/distance_helper.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/screens/trail/payment_info_widget.dart';
import 'package:darboda_rider/screens/trail/widgets/customer_widget.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.request});
  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.white12,
            Colors.black12,
            kPrimaryColor,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Amount to pay',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'TZS ${moneyFormat(request.amount!)}',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            PaymentInfoWidget(
              request: request,
            ),
          ],
        ),
      ),
    );
  }
}
