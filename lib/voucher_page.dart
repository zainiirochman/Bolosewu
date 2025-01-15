import 'package:bolosewu/pay_pulsa.dart';
import 'package:flutter/material.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voucher',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildVoucherTiles('assets/images/googlePlay.png', 'Google Play'),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherTiles (String imagePath, String name){
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PayPulsa()),
        );
      },
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.secondaryContainer
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black, // Warna bayangan
          //     spreadRadius: 2, // Area penyebaran bayangan
          //     blurRadius: 15, // Jarak blur bayangan
          //     offset: const Offset(2, 2), // Offset horizontal dan vertikal
          //   ),
          // ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(imagePath),
              ),
              SizedBox(width: 10,),
              Text(name),
            ],
          ),
        ),
      ),
    );
  }
}