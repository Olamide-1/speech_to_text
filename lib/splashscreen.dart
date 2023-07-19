import 'package:flutter/material.dart';
import 'package:speech_app/login.dart';
import 'dart:async';

import 'package:speech_app/welcome.dart';
//import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        //MaterialPageRoute(builder: (context) => HomePage()),
        MaterialPageRoute(builder: (context) => LoginPage()),
        //MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFba55d3),
      //backgroundColor: Colors.deepPurple,
      //backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image.asset('images/VOICEY.png'),
            Image.asset('images/1.png'),
            //Image.asset('images/sound logo.png'),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
