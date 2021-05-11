import 'package:flutter/material.dart';

class Donate extends StatefulWidget {
  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Donate',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
