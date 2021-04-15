//import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_app/main.dart';
import '../main.dart';
import 'Home_page.dart';
import 'Blood_Donation.dart';
import 'Account_Info.dart';
import 'package:page_transition/page_transition.dart';

class Charity extends StatefulWidget {
  @override
  _CharityState createState() => _CharityState();
}

class _CharityState extends State<Charity> {
  bool _colorHome = false;
  bool _colorCharity = true;
  bool _colorBloodDonations = false;
  bool _colorAccountInfo = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  Map info;
  void readData() {
    databaseReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value['DataBase'];
      for(var key in values.values) {
        if(key['Email'] == _auth.currentUser.email) {
          info = {
            'Name': key['Name'],
            'Email': key['Email'],
            'Password': key['Password'],
            'Date Of Birth': key['Date Of Birth'],
            'Age': key['Age'],
            'Phone Number': key['Phone Number'],
            'Blood Type': key['Blood Type'],
          };
          break;
        }
      }

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
      Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              minWidth: _size.width*0.25,
              height: _size.height*0.057,
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
              child: Image.asset('Images/home.png',height: _size.height*0.04,color: Colors.blueAccent,),
            ),
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
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
              },
              child: Image.asset(
                'Images/charity.png',
                height: _size.height*0.04,
              ),
            ),
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
              color: _colorBloodDonations ? Colors.grey[200] : Colors.white,
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
                height: _size.height*0.04,
              ),
            ),
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
              color: _colorAccountInfo ? Colors.grey[200] : Colors.white,
              onPressed: () {
                setState(() {
                  _colorAccountInfo = true;
                  if (_colorAccountInfo) {
                    _colorHome = false;
                    _colorBloodDonations = false;
                    _colorCharity = false;
                  }
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                    if(info != null) {
                      timer.cancel();
                      Navigator.push(
                          context,
                          PageTransition(
                              child: Account_Info(info))
                      );
                    }
                  });
                });
              },
              child: Image.asset('Images/account_circle.png', height: _size.height*0.04,color: Colors.blue,),
            ),
          ]),
        ],
      ),
    );
  }
}
