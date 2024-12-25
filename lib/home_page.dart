import 'package:bolosewu/auth.dart';
import 'package:bolosewu/games_page.dart';
import 'package:bolosewu/pulsa_page.dart';
import 'package:bolosewu/voucher_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _userUid() {
    return Text(
      user?.email ?? 'User Email',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bolosewu'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(200.0),
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: [
                    'https://store.bolosewu.xyz/assets/images/banner/1726042884_caabe11bf9dbe4e792a9.png',
                    'https://store.bolosewu.xyz/assets/images/banner/1726042884_caabe11bf9dbe4e792a9.png',
                    'https://store.bolosewu.xyz/assets/images/banner/1726042884_caabe11bf9dbe4e792a9.png'
                  ].map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                          ),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Header Drawer
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    _userUid(),
                  ],
                ),
              ),
              // Menu Items
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings page or perform any action
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to about page or perform any action
                },
              ),
              const Divider(), // Separator
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  signOut();
                  // Handle logout
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GamesPage(),
            VoucherPage(),
            PulsaPage(),
          ],
        ),
      ),
    );
  }
}