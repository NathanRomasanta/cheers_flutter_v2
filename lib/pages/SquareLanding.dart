import 'package:cheers_flutter/pages/SquareTest.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SquareLanding extends StatefulWidget {
  const SquareLanding({super.key});

  @override
  State<SquareLanding> createState() => _SquareLandingState();
}

class _SquareLandingState extends State<SquareLanding> {
  Future<void> processPayment(String sourceId, int amount, String currency,
      String idempotencyKey) async {
    final url = Uri.parse('https://connect.squareup.com/v2/payments');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer EAAAl2Z_o5qQoOnrBsSWk4YxnjGxCkJLyhAJmnC3-_CqLEx30JT8Y_2kEqEC2zwt', // Use your access token here
      },
      body: json.encode({
        'sourceId': sourceId,
        'amountMoney': {
          'currency': currency,
          'amount': amount,
        },
        'idempotencyKey': idempotencyKey,
        'acceptPartialAuthorization': true,
        'autocomplete': false,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print('Payment successful: ${responseBody}');
    } else {
      print('Failed to process payment: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              processPayment("cnon:card-nonce-ok", 10, "CAD",
                  "1004e4b8-d120-4dbe-9ec6-1b88c48ee2c8");
            },
            child: Text("Go to payments")),
      ),
    );
  }
}
