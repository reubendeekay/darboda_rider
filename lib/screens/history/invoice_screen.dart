// ignore_for_file: must_be_immutable

import 'dart:typed_data';

import 'package:darboda_rider/helpers/distance_helper.dart';
import 'package:darboda_rider/models/request_model.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/screens/history/generate_invoice.dart';
import 'package:darboda_rider/widgets/primary_button.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ticket_widget/ticket_widget.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({Key? key, required this.request}) : super(key: key);
  final RequestModel request;

  WidgetsToImageController controller = WidgetsToImageController();

  Uint8List? bytes;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    Widget invoice = Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TicketWidget(
        width: double.infinity,
        height: double.infinity,
        isCornerRounded: true,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Text(
              '#${request.id!}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Center(
            child: QrImage(
              data: request.id!,
              version: 4,
              size: 190.0.h,
            ),
          ),
          const Divider(),
          SizedBox(
            height: 15.h,
          ),
          info('Name', user.name!),
          SizedBox(
            height: 10.h,
          ),
          info('Rider', request.rider!.name!),
          SizedBox(
            height: 10.h,
          ),
          info('Pickup', request.pickupAddress!),
          SizedBox(
            height: 10.h,
          ),
          info('Destination', request.destinationAddress!),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  child: info(
                      'Date',
                      DateFormat('MMM dd, yyyy')
                          .format(request.timestamp!.toDate()))),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  child: info(
                      'Time',
                      DateFormat('hh:mm a')
                          .format(request.timestamp!.toDate()))),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  child: info('Amount', 'TZS ${moneyFormat(request.amount!)}')),
              const SizedBox(
                width: 15,
              ),
              Expanded(child: info('Payment Method', 'Cash')),
            ],
          ),
        ]),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: WidgetsToImage(
              controller: controller,
              child: invoice,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                PrimaryButton(
                    text: 'Download Invoice',
                    onTap: () async {
                      final bytes = await controller.capture();
                      final pdf = pw.Document();

                      final image = pw.MemoryImage(bytes!);

                      pdf.addPage(pw.Page(build: (pw.Context context) {
                        return pw.Center(
                          child: pw.Image(image),
                        ); // Center
                      }));
                      final file = await PdfApi.saveDocument(
                          name: 'Invoice.pdf', pdf: pdf);
                      await PdfApi.openFile(file);
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(
          height: 2.5,
        ),
        Text(value)
      ],
    );
  }
}
