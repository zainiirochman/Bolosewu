import 'package:bolosewu/top_up_page.dart';
import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildGamesTiles('assets/images/mobileLegends.png', 'Mobile Legends'),
            SizedBox(height: 20,),
            _buildGamesTiles('assets/images/freeFire.png', 'Free Fire'),
            SizedBox(height: 20,),
            _buildGamesTiles('assets/images/pubg.png', 'PUBG Mobile')
          ],
        ),
      ),
    );
  }

  Widget _buildGamesTiles (String imagePath, String name){
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopUpPage()),
        );
      },
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1,
            color: Colors.grey
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