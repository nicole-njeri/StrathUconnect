import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; 

void main() {
  runApp(StrathUConnectApp());
}

class StrathUConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrathUConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      home: HomeScreen(), // <-- This must point to your custom HomeScreen
    );
  }
}
