//import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'Home_page.dart';
import 'Charity.dart';
import 'Blood_Donation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Account_Info extends StatefulWidget {
  @override
  _Account_InfoState createState() => _Account_InfoState();
}

class _Account_InfoState extends State<Account_Info> {
  bool _colorHome = false;
  bool _colorCharity = false;
  bool _colorBloodDonations = false;
  bool _colorAccountInfo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
          child: Stack(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    height: 50,
                    color: _colorHome ? Colors.grey[200] : Colors.white,
                    onPressed: () {
                      setState(() {
                        _colorHome = true;
                        if (_colorHome) {
                          _colorCharity = false;
                          _colorBloodDonations = false;
                          _colorAccountInfo = false;
                        }
                      });
                      Navigator.push(
                          context,
                          PageTransition(
                            child: Home_page(),
                          ));
                    },
                    child: Icon(
                      Icons.home,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  FlatButton(
                    height: 50,
                    color: _colorCharity ? Colors.grey[200] : Colors.white,
                    onPressed: () {
                      setState(() {
                        _colorCharity = true;
                        if (_colorCharity) {
                          _colorHome = false;
                          _colorBloodDonations = false;
                          _colorAccountInfo = false;
                        }
                      });
                      Navigator.push(
                          context,
                          PageTransition(
                            child: Charity(),
                          ));
                    },
                    child: Image.asset(
                      'Images/charity.png',
                      height: 35,
                    ),
                  ),
                  FlatButton(
                    height: 50,
                    color:
                        _colorBloodDonations ? Colors.grey[200] : Colors.white,
                    onPressed: () {
                      setState(() {
                        _colorBloodDonations = true;
                        if (_colorBloodDonations) {
                          _colorHome = false;
                          _colorCharity = false;
                          _colorAccountInfo = false;
                        }
                      });
                      Navigator.push(
                          context,
                          PageTransition(
                            child: Blood_Donation(),
                          ));
                    },
                    child: Image(
                      image: AssetImage('Images/blood_donation_color.png'),
                      height: 40,
                    ),
                  ),
                  FlatButton(
                    height: 50,
                    color: _colorAccountInfo ? Colors.grey[200] : Colors.white,
                    onPressed: () {
                      setState(() {
                        _colorAccountInfo = true;
                        if (_colorAccountInfo) {
                          _colorHome = false;
                          _colorBloodDonations = false;
                          _colorCharity = false;
                        }
                      });
                    },
                    child: Icon(
                      Icons.account_circle,
                      size: 35,
                      color: Colors.blue[400],
                    ),
                  ),
                ]),
          ],
        ),
      ])),
    );
  }
}
