import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bolosewu/widget_tree.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const WidgetTree(),
      theme: ThemeData(
        textTheme: TextTheme(
          titleLarge: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w400
          ),
          titleMedium: TextStyle(
              color: Colors.purple,
              fontSize: 20,
              fontWeight: FontWeight.w600
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          displayMedium: TextStyle(
            color: Colors.purple,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.white,
          secondary: Colors.purple,
          primaryContainer: Colors.white,
          secondaryContainer: Colors.purple,
          surface: Colors.white,
          onSurface: Colors.black54,
        ),
      ),
    );
  }
}