import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SquarePaymentPage extends StatefulWidget {
  const SquarePaymentPage({Key? key}) : super(key: key);

  @override
  _SquarePaymentPageState createState() => _SquarePaymentPageState();
}

class _SquarePaymentPageState extends State<SquarePaymentPage> {
  final TextEditingController _totalController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = '';
    });
  }

  Future<void> _processPayment() async {
    _clearError();

    if (_totalController.text.isEmpty) {
      _setError('Please enter a total amount');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      double totalAmount = double.parse(_totalController.text);
      if (totalAmount <= 0) {
        _setError('Please enter a valid amount greater than 0');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert to cents (Square expects amount in smallest currency unit)
      int amountInCents = (totalAmount * 100).round();

      // First, create a payment in the Square API
      final response = await _createSquarePayment(amountInCents);

      if (response['success'] == true && response['checkoutUrl'] != null) {
        // Launch the Square checkout URL
        final Uri squareCheckoutUrl = Uri.parse(response['checkoutUrl']);
        if (await canLaunchUrl(squareCheckoutUrl)) {
          await launchUrl(squareCheckoutUrl,
              mode: LaunchMode.externalApplication);
        } else {
          _setError(
              'Could not launch Square checkout. Please try again later.');
        }
      } else {
        _setError(
            'Failed to create payment: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _createSquarePayment(int amountInCents) async {
    try {
      // Replace with your actual backend API endpoint that communicates with Square
      final url =
          Uri.parse('https://your-backend-api.com/create-square-payment');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_SERVER_SIDE_API_KEY', // Your server should handle this securely
        },
        body: jsonEncode({
          'amount_money': {'amount': amountInCents, 'currency': 'USD'},
          'idempotency_key': DateTime.now().millisecondsSinceEpoch.toString(),
          'redirect_url': 'your-app-scheme://payment-complete'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'checkoutUrl': data['checkout']['checkout_page_url']
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // This is a mock implementation for testing without a backend
  Future<Map<String, dynamic>> _mockCreateSquarePayment(
      int amountInCents) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For testing: This would normally come from your backend calling Square API
    return {
      'success': true,
      'checkoutUrl':
          'https://connect.squareup.com/v2/checkout?c=CHECKOUT_ID_FROM_SQUARE_API'
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Square Payment Test (v2 API)'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Payment Total',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _totalController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Amount',
                  hintText: 'Enter the total payment amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Process Payment with Square',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// If you're using this as part of a larger app with MaterialApp already defined:
class SquarePaymentWidget extends StatefulWidget {
  const SquarePaymentWidget({Key? key}) : super(key: key);

  @override
  _SquarePaymentWidgetState createState() => _SquarePaymentWidgetState();
}

class _SquarePaymentWidgetState extends State<SquarePaymentWidget> {
  final TextEditingController _totalController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = '';
    });
  }

  Future<void> _processPayment() async {
    _clearError();

    if (_totalController.text.isEmpty) {
      _setError('Please enter a total amount');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      double totalAmount = double.parse(_totalController.text);
      if (totalAmount <= 0) {
        _setError('Please enter a valid amount greater than 0');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert to cents
      int amountInCents = (totalAmount * 100).round();

      // For a real implementation, you would call your backend API here
      // This is just a mock for testing
      final response = await _mockCreateSquarePayment(amountInCents);

      if (response['success'] == true && response['checkoutUrl'] != null) {
        final Uri squareCheckoutUrl = Uri.parse(response['checkoutUrl']);
        if (await canLaunchUrl(squareCheckoutUrl)) {
          await launchUrl(squareCheckoutUrl,
              mode: LaunchMode.externalApplication);
        } else {
          _setError(
              'Could not launch Square checkout. Please try again later.');
        }
      } else {
        _setError(
            'Failed to create payment: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mock implementation for testing
  Future<Map<String, dynamic>> _mockCreateSquarePayment(
      int amountInCents) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'checkoutUrl':
          'https://connect.squareup.com/v2/checkout?c=CHECKOUT_ID_FROM_SQUARE_API'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
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
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
