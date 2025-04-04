import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SquarePaymentPage extends StatefulWidget {
  @override
  _SquarePaymentPageState createState() => _SquarePaymentPageState();
}

class _SquarePaymentPageState extends State<SquarePaymentPage> {
  final String squareApplicationId =
      "sq0idp-KmV2UERfVsNgK4OXxudrsg"; // Replace with your Square App ID
  final String locationId =
      "LFKDEW3604575"; // Replace with your Square Location ID
  final String squareAccessToken =
      "EAAAl2wBan9Hwz6ZDxLvH_eC0itywIeS4393ZkRQGxp0hdM15gtl39eKMPWdey3x"; // Replace with your Square Access Token

  String? lastPaymentId;
  String paymentStatus = "Not Checked";

  /// Function to open Square POS for payment
  void openSquarePOS(int amountCents) async {
    String paymentId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Unique ID for payment
    setState(() {
      lastPaymentId = paymentId;
      paymentStatus = "Waiting for payment...";
    });

    String url = "square://payments/create?"
        "amount_cents=$amountCents&"
        "currency_code=USD&"
        "client_id=$squareApplicationId&"
        "location_id=$locationId&"
        "idempotency_key=$paymentId"; // Unique transaction key

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint("Could not open Square POS app.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Square POS app not installed."),
      ));
    }
  }

  /// Function to check the payment status via Square API
  Future<void> checkPaymentStatus() async {
    if (lastPaymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No payment found. Please make a payment first."),
      ));
      return;
    }

    var url =
        Uri.parse("https://connect.squareup.com/v2/payments/$lastPaymentId");

    var response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $squareAccessToken",
        "Square-Version": "2023-12-13",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        paymentStatus = jsonResponse['payment']['status'];
      });
    } else {
      setState(() {
        paymentStatus = "Failed to check payment. Error: ${response.body}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Square Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () =>
                  openSquarePOS(5000), // Example: $50.00 (5000 cents)
              child: Text("Pay with Square POS"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: lastPaymentId != null ? checkPaymentStatus : null,
              child: Text("Check Payment Status"),
            ),
            SizedBox(height: 20),
            Text(
              "Payment Status: $paymentStatus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
