import 'dart:math';
import 'package:flutter/material.dart';
import 'payment_documentation_page.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String selectedNetwork = 'MTN';

  bool _loading = false;
  Map<String, dynamic>? _lastApiResponse;
  String? _statusMessage;

  // Phone validation for Ugandan numbers (starts with +2567 or 07)
  bool isValidPhoneNumber(String phone) {
    final pattern = RegExp(r'^(?:\+256|0)7\d{8}$');
    return pattern.hasMatch(phone);
  }

  // Simulated MoMo API call
  Future<Map<String, dynamic>> fakeMoMoApiCall({
    required String phoneNumber,
    required int amount,
    required String network,
  }) async {
    await Future.delayed(const Duration(seconds: 3)); // simulate network delay

    final random = Random();
    bool success = random.nextBool();

    String transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    String timestamp = DateTime.now().toUtc().toIso8601String();

    if (success) {
      return {
        "transactionId": transactionId,
        "status": "SUCCESS",
        "amount": amount,
        "currency": "UGX",
        "phoneNumber": phoneNumber,
        "network": network,
        "timestamp": timestamp,
        "message": "Payment completed successfully."
      };
    } else {
      return {
        "transactionId": transactionId,
        "status": "FAILED",
        "amount": amount,
        "currency": "UGX",
        "phoneNumber": phoneNumber,
        "network": network,
        "timestamp": timestamp,
        "message": "Payment failed due to network error. Please try again."
      };
    }
  }

  // Generates a unique 6-digit numeric code with no repeated digits
  String generateUniqueNumberCode(int length) {
    if (length > 10) {
      throw ArgumentError('Cannot have more than 10 unique digits');
    }
    final digits = List<int>.generate(10, (i) => i);
    digits.shuffle(Random());
    return digits.take(length).join();
  }

  void submitDonation() async {
    String amountText = _amountController.text.trim();
    String phone = _phoneController.text.trim();

    if (amountText.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all required details')),
      );
      return;
    }

    if (!isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Ugandan phone number')),
      );
      return;
    }

    int? amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid donation amount')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = "Processing your payment...";
      _lastApiResponse = null;
    });

    // Show loading dialog (optional, you can rely on inline _loading too)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Processing Donation Please Wait...'),
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    // Simulate API call
    Map<String, dynamic> apiResponse = await fakeMoMoApiCall(
      phoneNumber: phone,
      amount: amount,
      network: selectedNetwork,
    );

    // Close loading dialog
    Navigator.pop(context);

    setState(() {
      _loading = false;
      _lastApiResponse = apiResponse;
      _statusMessage = apiResponse['message'];
    });

    // Generate access code
    String accessCode = generateUniqueNumberCode(6);

    // Show confirmation dialog based on API response
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: apiResponse['status'] == 'SUCCESS'
            ? const Text('Donation Successful 🎉')
            : const Text('Donation Failed ⚠️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${apiResponse['transactionId']}'),
            Text('Amount: UGX ${apiResponse['amount']} via ${apiResponse['network']}'),
            const SizedBox(height: 10),
            if (apiResponse['status'] == 'SUCCESS') ...[
              Text('✅ Your Access Code: $accessCode'),
              const SizedBox(height: 10),
              const Text('🙏 Thank you! May God bless you for your kindness.'),
              const SizedBox(height: 10),
              const Text('🛰️ MoMo API has been contacted successfully.'),
            ] else ...[
              const Text('Please try again later or check your network.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Button to navigate to Documentation Page
  void openDocumentationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentDocumentationPage()),
    );
  }

  Widget _buildApiResponseLog() {
    if (_lastApiResponse == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          _lastApiResponse.toString(),
          style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate with MTN MoMo'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'e.g. 0770123456',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (UGX)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedNetwork,
                  items: const [
                    DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                    DropdownMenuItem(value: 'Airtel', child: Text('Airtel')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedNetwork = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Network',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loading ? null : submitDonation,
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Donate Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _lastApiResponse != null && _lastApiResponse!['status'] == 'SUCCESS'
                          ? Colors.green
                          : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                _buildApiResponseLog(),
                const SizedBox(height: 100), // leave space for floating button
              ],
            ),
          ),
          // Animated Floating Documentation Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              offset: const Offset(0, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: 1.0,
                child: ElevatedButton.icon(
                  onPressed: openDocumentationPage,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('How MoMo Payments Work'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
