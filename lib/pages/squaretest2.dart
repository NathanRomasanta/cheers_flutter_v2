import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SquareTesting2 extends StatefulWidget {
  const SquareTesting2({super.key});

  @override
  State<SquareTesting2> createState() => _SquareTesting2State();
}

class _SquareTesting2State extends State<SquareTesting2> {
  final TextEditingController _totalController = TextEditingController();
  Future<void> _processPayment() async {
    try {
      double totalAmount = double.parse(_totalController.text);

      // Convert to cents (Square expects amount in cents)
      int amountInCents = (totalAmount * 100).round();

      // Build the Square Point of Sale API URL
      // Replace YOUR_SQUARE_APPLICATION_ID with your actual Square application ID
      final Uri squareUrl = Uri.parse(
          'square-commerce-v1://payment/create?client_id=sq0idp-KmV2UERfVsNgK4OXxudrsg&amount_money[amount]=$amountInCents&amount_money[currency]=USD&callback_url=your-app-scheme://payment-complete');

      // Launch the Square app
      if (await canLaunchUrl(squareUrl)) {
        await launchUrl(squareUrl);
      } else {}
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter Payment Total',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _totalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Total Amount',
              hintText: 'Enter the total payment amount',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Process Payment with Square',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
