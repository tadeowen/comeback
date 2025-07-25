import 'package:flutter/material.dart';

class PaymentDocumentationPage extends StatelessWidget {
  const PaymentDocumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Documentation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              '📄 MoMo API Donation Flow ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '1. User enters their phone number and donation amount.',
            ),
            Text(
              '2. User selects MTN or Airtel as the payment method.',
            ),
            Text(
              '3. App simulates contacting MoMo API (not real money).',
            ),
            Text(
              '4. A unique access code is generated and shown.',
            ),
            Text(
              '5. A success dialog confirms the donation process.',
            ),
            SizedBox(height: 20),
            Text(
              '❗ Note: This is a simulation. No real money is transferred.\n\n'
              'This flow mimics how real APIs like MTN MoMo work, but without real backend connection.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
