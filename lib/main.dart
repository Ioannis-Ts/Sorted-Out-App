import 'package:flutter/material.dart';
import 'login.dart'; // Import the LoginScreen class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Use LoginScreen here
    );
  }
}
