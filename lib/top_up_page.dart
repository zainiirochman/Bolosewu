import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tripay_api.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TripayAPI tripayAPI = TripayAPI();
  final TextEditingController _amountController = TextEditingController();
  List<dynamic> _paymentChannels = [];
  String? _selectedChannel;
  String? _selectedGridAmount; // For grid selection

  final List<String> _gridAmounts = [
    '10,000',
    '20,000',
    '50,000',
    '100,000',
    '200,000',
    '500,000',
  ]; // Predefined grid amounts

  @override
  void initState() {
    super.initState();
    _fetchPaymentChannels();
  }

  Future<void> _fetchPaymentChannels() async {
    try {
      final channels = await tripayAPI.getPaymentChannels();
      setState(() {
        _paymentChannels = channels;
      });
    } catch (e) {
      print('Error fetching payment channels: $e');
    }
  }

  Future<void> _createTransaction() async {
    final amount = _selectedGridAmount ?? _amountController.text;
    if (_selectedChannel == null || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method and amount')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final transaction = await tripayAPI.createTransaction(
        method: _selectedChannel!,
        amount: amount.replaceAll(',', ''), // Remove commas for API
        userEmail: user?.email ?? 'user@example.com',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction Created: ${transaction['reference']}')),
      );
    } catch (e) {
      print('Error creating transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Amount:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10, // Space between columns
                  mainAxisSpacing: 10, // Space between rows
                  childAspectRatio: 2.5, // Aspect ratio of each item
                ),
                itemCount: _gridAmounts.length,
                itemBuilder: (context, index) {
                  final amount = _gridAmounts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGridAmount = amount;
                        _amountController.clear(); // Clear manual input
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedGridAmount == amount
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Rp $amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedGridAmount == amount
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Or Enter Amount Manually:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedGridAmount = null; // Clear grid selection
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g., 100000)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Payment Method'),
              value: _selectedChannel,
              items: _paymentChannels.map<DropdownMenuItem<String>>((channel) {
                return DropdownMenuItem<String>(
                  value: channel['code'],
                  child: Text(channel['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChannel = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTransaction,
              child: const Text('Create Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
