import 'dart:convert';
import 'package:http/http.dart' as http;

class TripayAPI {
  final String apiKey = 'YOUR_TRIPAY_API_KEY'; // Ganti dengan API Key Tripay
  final String baseUrl = 'https://tripay.co.id/api';

  Future<List<dynamic>> getPaymentChannels() async {
    final url = Uri.parse('$baseUrl/merchant/payment-channel');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $apiKey'});
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load payment channels');
    }
  }

  Future<Map<String, dynamic>> createTransaction(
      {required String method, required String amount, required String userEmail}) async {
    final url = Uri.parse('$baseUrl/transaction/create');
    final body = {
      'method': method,
      'merchant_ref': 'TX12345',
      'amount': amount,
      'customer_name': userEmail,
      'customer_email': userEmail,
    };
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $apiKey'},
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to create transaction');
    }
  }
}
