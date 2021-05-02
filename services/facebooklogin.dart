import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Home_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/cupertino.dart';


import '../main.dart';

class LoginWithFacebook extends StatefulWidget {
  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {

  bool _isLogin = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FacebookLogin _facebookLogin = FacebookLogin();
  User _user;
  DatabaseReference _ref = FirebaseDatabase.instance.reference().child('DataBase');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#3b5998"),
      body: Center(
        child: Container(
          height: 40,
          color: Colors.transparent,
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  //style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
                color: HexColor("#3b5998"),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      onTap: () async{
                        setState(() {
                          _handleLogin();
                        });

                      },
                      child: Row(
                        children: [
                          Image.asset('Images/facebook.png',color: Colors.white,),
                          SizedBox(width: 10),
                          Text(
                            'Login with Facebook',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf'),
                          )],)
                  ),
                ],
              )),
        ),
      ) /*Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             CircleAvatar(
               radius: 80,
               backgroundImage: NetworkImage(_user.photoURL),
             ),
            Text(_user.displayName),
            SizedBox(height: 30),
            OutlineButton(onPressed: () async {
              await _signOut();
            })
          ],
        )
      ),*/
    );
  }
  Future _handleLogin() async {

    FacebookLoginResult _result =  await _facebookLogin.logIn(['email']);
    switch(_result.status)
    {
      case FacebookLoginStatus.cancelledByUser:
        print('Cancelled By User');
        break;
      case FacebookLoginStatus.error:
        print('Error');
        break;
      case FacebookLoginStatus.loggedIn:
        saveInfo();
        await _loginWithFacebook(_result).then((_)
        {
          Navigator.push(
              context,
              PageTransition(
                  child: Home_page())
          );
        });

        break;
    }
  }
  Future _loginWithFacebook(FacebookLoginResult _result) async{
    FacebookAccessToken _accessToken = _result.accessToken;
    AuthCredential _credential = FacebookAuthProvider.credential(_accessToken.token);
    var a = await _auth.signInWithCredential(_credential);
    setState(() {
      _isLogin = true;
      _user = a.user;
    });
  }

 /* Future _signOut() async {
    await _auth.signOut().then((value) {
      _facebookLogin.logOut();
      _isLogin = false;

    });
  }*/
  void saveInfo() async{
    String name = 'N/A';
    String email = 'N/A';
    String dob = 'N/A';
    String bloodType = 'N/A';
    String age = 'N/A';
    String phoneNumber = 'N/A';
    Map<String, String> info = {
      'Name': name,
      'Email': email,
      'Date Of Birth': dob,
      'Age': age,
      'Blood Type': bloodType,
      'Phone Number': phoneNumber,
    };
    _ref.push().set(info);
  }
}


