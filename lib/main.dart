//import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Forgot_Password.dart';
import 'package:flutter_app/interfaces/Home_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'interfaces/Signup_interface.dart';
import 'services/facebooklogin.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //  The WidgetFlutterBinding is used to interact with the Flutter engine.
  // Firebase.initializeApp() needs to call native code to initialize Firebase,
  // and since the plugin needs to use platform channels to call the native code,
  // which is done asynchronously therefore you have to call ensureInitialized() to make sure that
  // you have an instance of the WidgetsBinding.

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // This banner is intended to deter people from complaining that
    // your app is slow when it's in checked mode. In checked mode,
    // Flutter enables a large number of expensive diagnostics to aid in development,
    // and so performance in checked mode is not representative of what will happen in release mode.
    routes: {
      '/': (context) => Home(),
      '/SignupInterface': (context) => Signup_interface(),
    },
  ));
}

class Home extends StatelessWidget {

  TextEditingController _email = TextEditingController();

  TextEditingController _password = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final _emailFill = GlobalKey<FormState>();
    final _passwordFill = GlobalKey<FormState>();
    String error;
    return Scaffold(
      backgroundColor: Colors.green[50],
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: [Stack(
            children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Images/Project-Topi.png',),
                // fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(
                    Colors.green[50].withOpacity(0.3), BlendMode.dstATop),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                      child: Text(
                        'Project',
                        style: TextStyle(
                          fontSize: 70,
                          fontFamily: 'Montserrat-Black.tff',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 180, 0, 0),
                      child: Text(
                        'Topi',
                        style: TextStyle(
                          fontSize: 70,
                          fontFamily: 'Montserrat-Black.tff',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 20),
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _emailFill,
                      child: TextFormField(
                        validator: (value) {
                          if (!value.contains("@")) return 'Invalid Email!';
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: _email,
                        decoration: InputDecoration(
                          hintText: 'Someone@example.com',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Form(
                      key: _passwordFill,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        controller: _password,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment(1, 0),
                      padding: EdgeInsets.only(top: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  duration: Duration(milliseconds: 500),
                                  child: Forgot_Password()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.grey[500],
                              letterSpacing: 0.3,
                              fontFamily: 'Montserrat-Thin.tff'),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      height: 40,
                      child: Material(
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.greenAccent,
                          color: Colors.green,
                          elevation: 7,
                          child: InkWell(
                            onTap: () async {
                              if (_emailFill.currentState.validate() &&
                                  _passwordFill.currentState.validate()) {
                                dynamic result = await _auth
                                    .signInWithEmailAndPassword(
                                    email: _email.text,
                                    password: _password.text).then((_) {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.bottomToTop,
                                          duration: Duration(milliseconds: 500),
                                          child: Home_page()));
                                }).catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                          Text('Invalid Email or Password')));
                                });
                              }
                            },
                            child: Center(
                                child: Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat-Thin.tff',
                                      fontSize: 20,
                                    ))),
                          )),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 40,
                      color: Colors.transparent,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              //style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: HexColor("#3b5998"),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.bottomToTop,
                                            duration: Duration(milliseconds: 500),
                                            child: LoginWithFacebook()));
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'Images/facebook.png',
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Login with Facebook',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Montserrat-Thin.ttf'),
                                      )
                                    ],
                                  )),
                            ],
                          )),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'New to Project-Topi?',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Thin.ttf',
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    duration: Duration(milliseconds: 500),
                                    child: Signup_interface()));
                          },
                          child: Text('Register',
                              style: TextStyle(
                                color: Colors.green,
                                decoration: TextDecoration.underline,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
        ]
      ),
    );
  }
}
