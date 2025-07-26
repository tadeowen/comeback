import 'dart:convert';
import 'package:http/http.dart' as http;

class MtnMomoService {
  static const String baseUrl = 'https://sandbox.momodeveloper.mtn.com';
  static const String subscriptionKey = '7caed3074eec42ccb2619e4a8c654fa0';
  static const String targetEnvironment = 'sandbox';

  // Replace this with a real token later
  static const String accessToken = 'REPLACE_WITH_YOUR_ACCESS_TOKEN';

  static Future<void> requestDonation() async {
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();

    final response = await http.post(
      Uri.parse('$baseUrl/collection/v1_0/requesttopay'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'X-Reference-Id': uuid,
        'X-Target-Environment': targetEnvironment,
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "amount": "1000",
        "currency": "EUR",
        "externalId": uuid,
        "payer": {
          "partyIdType": "MSISDN",
          "partyId": "256772123456"
        },
        "payerMessage": "Donation to Comeback App",
        "payeeNote": "Thank you!"
      }),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}

