//import 'dart:convert';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import 'Home_page.dart';
import 'Charity.dart';
import 'Blood_Donation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'Loading_Screen.dart';

class Account_Info extends StatefulWidget {
  Map info;
  Account_Info(this.info, {Key,key}) : super(key:key);
  @override
  _Account_InfoState createState() => _Account_InfoState();
}

class _Account_InfoState extends State<Account_Info> {
  TextEditingController name = TextEditingController();
  TextEditingController bloodType = TextEditingController();
  bool _colorHome = false;
  bool _colorCharity = false;
  bool _colorBloodDonations = false;
  final _nameChange = GlobalKey<FormState>();
  final _bloodTypeChange = GlobalKey<FormState>();
  bool _colorAccountInfo = true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool editName = false;
  bool editBloodType = false;
  User _user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = _auth.currentUser;
  }
  @override
  Widget build(BuildContext context) {
    child: Text(widget.info.toString());
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
    backgroundColor: Colors.grey[200],
    body: Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: _size.height*0.2,horizontal: _size.width*0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('NAME',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,

                  )),
              SizedBox(width: 40,),
              editName?  Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Form(
                      key: _nameChange,
                      child: TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'FULL NAME',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            editName = false;
                          });
                        },
                    child: Image.asset('Images/check.png',height: _size.height*0.03,)
                  ))
                ],
              ): Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.info['Name'].toString(),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        letterSpacing: 2,
                        fontSize: 20,
                      )),
                  TextButton(onPressed: () {
                    setState(() {
                      editName = true;
                    });
                  }, child: Image.asset('Images/edit.png',height: _size.height*0.03,)),
                ],
              ),
              SizedBox(height: 20),
              Text('BLOOD GROUP',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  )),
              SizedBox(height: 8),
              editBloodType?  Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Form(
                      key: _bloodTypeChange,
                      child: TextFormField(
                        controller: bloodType,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'BLOOD TYPE',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              editBloodType = false;
                            });
                          },
                          child: Image.asset('Images/check.png',height: _size.height*0.03,)
                      ))
                ],
              ): Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.info['Blood Type'].toString(),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        letterSpacing: 2,
                        fontSize: 20,
                      )),
                  TextButton(onPressed: () {
                    setState(() {
                      editBloodType = true;
                    });
                  }, child: Image.asset('Images/edit.png',height: _size.height*0.03,)),
                ],
              ),
              SizedBox(height: 20),
              Text('AGE',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,

                  )),
              SizedBox(height: 8),
              Text(widget.info['Age'].toString(),
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20,
                    letterSpacing: 2,

                  )),
              SizedBox(height: 150),
              InkWell(onTap: () => _auth.signOut().then((_) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
              child: Row(
                children: [
                  Text('Logout',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat-Thin.tff',
                        fontSize: 20,
                      )),
                  SizedBox(width: 10,),
                  Image( image: AssetImage('Images/signout.png',),height: _size.height*0.03,color: Colors.blueAccent),
                ],
              )),
            ],
          ),
        ),
        Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
      Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
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
                Navigator.push(
                    context,
                    PageTransition(
                      child: Charity(),
                    ));
              },
              child: Image.asset(
                'Images/charity.png',
                height: _size.height*0.04,
              ),
            ),
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
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
                  height: _size.height*0.04,
              ),
            ),
            FlatButton(
              height: _size.height*0.057,
              minWidth: _size.width*0.25,
              color: _colorAccountInfo ? Colors.grey[200] : Colors.white,
              onPressed: () {
                print('Name: ' + _user.displayName + "\nPhotoURL: " + _user.photoURL);
                setState(() {
                  _colorAccountInfo = true;
                  if (_colorAccountInfo) {
                    _colorHome = false;
                    _colorBloodDonations = false;
                    _colorCharity = false;
                  }
                });
              },
              child: Image.asset('Images/account_circle.png', height: _size.height*0.04,color: Colors.blue,),
            ),
          ]),
      ],
      ),
    ]
    ),
      );
  }
  Widget ChangeValue(String s) {
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value['DataBase'];
      databaseReference.child('DataBase').update({
        s: s,
      });

    });
  }
}

