import 'dart:async';
import 'dart:convert';
import 'package:bolosewu/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PayPulsa extends StatefulWidget {
  const PayPulsa({super.key});

  @override
  State<PayPulsa> createState() => _PayPulsaState();
}

class _PayPulsaState extends State<PayPulsa> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<dynamic> _paymentChannels = [];
  String? _selectedChannel;
  String? _selectedGridAmount;

  final List<String> _gridAmounts = [
    '10,000',
    '20,000',
    '50,000',
    '100,000',
    '200,000',
    '500,000',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPaymentChannels();
  }

  void createData(String paymentStatus, String orderIdNya){
    String amountNya = _amountController.text;
    String phoneNya = _phoneController.text;

    if (amountNya.isEmpty || phoneNya.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap isi semua kolom!")),
      );
    } else {
      DocumentReference documentReference = FirebaseFirestore.instance.collection("${Auth().currentUser?.uid}").doc("${DateTime.now().millisecondsSinceEpoch}");

      Map<String, dynamic> transactionData = {
        "amount": amountNya,
        "phone": phoneNya,
        "status":paymentStatus,
        "orderId":orderIdNya,
      };

      documentReference.set(transactionData).then((_) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Data berhasil disimpan!")),
        // );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data: $error")),
        );
      });
    }
  }

  Future<void> _fetchPaymentChannels() async {
    try {
      final List<Map<String, String>> paymentChannels = [
        {"name": "Bank Transfer (BRI)", "code": "bank_transfer"},
      ];

      setState(() {
        _paymentChannels = paymentChannels;
      });
    } catch (e) {
      print('Error fetching payment channels: $e');
    }
  }

  void _createTransaction() {
    final amount = _selectedGridAmount?.replaceAll(',', '') ?? _amountController.text;
    final phone = _phoneController.text;

    if (amount.isEmpty || phone.isEmpty || _selectedChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    _payWithMidtrans(amount, phone, _selectedChannel!);
  }

  void _payWithMidtrans(String amount, String phone, String paymentCode) async {
    final url = Uri.parse('https://api.sandbox.midtrans.com/v2/charge');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('SB-Mid-server-r1A1xBVL7ChuK9GTKFlyg2sr'))}',
    };

    final body = {
      "payment_type": paymentCode,
      "transaction_details": {
        "order_id": "order-${DateTime.now().millisecondsSinceEpoch}",
        "gross_amount": int.parse(amount),
      },
      if (paymentCode == "bank_transfer")
        "bank_transfer": {
          "bank": "bri"
        },
      "item_details": [
        {
          "id": "pulsa-${int.parse(amount)}",
          "price": int.parse(amount),
          "quantity": 1,
          "name": "Pulsa Telkomsel"
        }
      ],
      "customer_details": {
        "first_name": Auth().currentUser?.displayName,
        "last_name": "",
        "email": Auth().currentUser?.email,
        "phone": phone,
      }
    };

    try {
      final response = await http.post(url, headers: headers, body: json.encode(body));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final orderId = responseData['order_id'];
        createData("Pending", orderId);

        final vaNumber = responseData['va_numbers']?[0]['va_number'];

        final selectedChannel = _paymentChannels.firstWhere(
              (channel) => channel['code'] == paymentCode,);
        _updateTransactionStatusInFirestore(orderId, "Pending");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Detail Pembayaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Metode: ${selectedChannel['name']}'),
                if (vaNumber != null) Row(
                  children: [
                    Text('VA: $vaNumber'),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: '$vaNumber'));
                      },
                    ),
                  ],
                ),
                Text('Nominal: Rp $amount'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ],
          ),
        );

        _checkTransactionStatus(orderId);
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi gagal: ${errorData['status_message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  void _checkTransactionStatus(String orderId) async {
    final url = Uri.parse('https://api.sandbox.midtrans.com/v2/$orderId/status');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('SB-Mid-server-r1A1xBVL7ChuK9GTKFlyg2sr'))}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final transactionStatus = responseData['transaction_status'];

        await _updateTransactionStatusInFirestore(orderId, transactionStatus);

        if (transactionStatus == 'settlement') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran berhasil!')),
          );
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Detail Pembayaran'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pembayaran anda berhasil!'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ],
            ),
          );
        } else if (transactionStatus == 'pending') {
          Timer(Duration(seconds: 5), () {
            _checkTransactionStatus(orderId);
          });
        } else if (transactionStatus == 'expire') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran kedaluwarsa!')),
          );
        } else if (transactionStatus == 'cancel') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran dibatalkan!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memeriksa status transaksi: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  Future<void> _updateTransactionStatusInFirestore(String orderId, String status) async {
    try {
      final userCollection = FirebaseFirestore.instance.collection("${Auth().currentUser?.uid}");

      final querySnapshot = await userCollection.where("orderId", isEqualTo: orderId).get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({"status": status});
      }
    } catch (error) {
      print("Gagal memperbarui status di Firestore: $error");
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
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Select Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: _gridAmounts.length,
                itemBuilder: (context, index) {
                  final amount = _gridAmounts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGridAmount = amount;
                        _amountController.clear();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedGridAmount == amount ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Rp $amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedGridAmount == amount ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Or Enter Amount Manually:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedGridAmount = null;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Payment Method:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
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
              onPressed: (){
                _createTransaction();
                // createData();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
