import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {

  final _auth = FirebaseAuth.instance;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = _auth.currentUser;
    print("User => " + _user.toString());
    _user.sendEmailVerification();
  }
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          children: [
            SizedBox(height: _size.height*0.45,),
            Card(
              margin: EdgeInsets.zero,

              elevation: 7,
              color: Colors.green[50],
              child: Text('A email has been sent to ${_user.email} for verification',
                style: TextStyle(
                  fontFamily: 'Montserrat-Light.tff',
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 30,),
            Container(
              height: 40,
              child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7,
                  child: InkWell(
                    onTap: () {
                      checkEmailVerified();
                    },
                    child: Center(
                        child: Text('Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat-Thin.tff',
                              fontSize: 20,
                            ))),
                  )),
            ),
          ],
        )
      )
    );
  }
  Future<void> checkEmailVerified() async{
    _user = _auth.currentUser;
    await _user.reload();
    if(_user.emailVerified)
      {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
  }
}