// ignore: avoid_web_libraries_in_flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/services/verifyEmail.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_database/firebase_database.dart';

class Signup_interface extends StatefulWidget {
  @override
  _Signup_interfaceState createState() => _Signup_interfaceState();
}

class _Signup_interfaceState extends State<Signup_interface> {
  TextEditingController _fullName, _email, _password, _age, _phoneNumber,_rePass;
  final _emailFill = GlobalKey<FormState>();
  final _passwordFill = GlobalKey<FormState>();
  final _rePassFill = GlobalKey<FormState>();
  final _fullNameFill = GlobalKey<FormState>();
  final _phoneNumberFill = GlobalKey<FormState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  List<String> _days = ['1'];
  var _currentDay = DateTime.now().day.toString();
  List<String> _months;
  var _currentMonth;
  List<String> _years = ['1970'];
  var _currentYear = DateTime.now().year.toString();
  DateTime _date;
  var _monthMap;
  DatabaseReference _ref;
  List<String> bloodgrps;
  var currentbgrp;
  bool _obscureTextPass = true;
  void _togglePass() {
    setState(() {
      _obscureTextPass = !_obscureTextPass;
    });
  }
    bool _obscureTextRePass = true;
    void _toggleRePass() {
      setState(() {
        _obscureTextRePass = !_obscureTextRePass;
      });
  }
  String age_calculator(int day,int month,int year){

    int currentDay = DateTime.now().day;
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    int age = currentYear - year;
    int month1 = currentMonth;
    int month2 = month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDay;
      int day2 = day;
      if (day2 > day1) {
        age--;
      }
    }
    return age.toString();
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _date = DateTime.now();
    _currentMonth = DateFormat('MMMM').format(_date);
    for (int i = 1; i < 31; i++) {
      _days.add((i + 1).toString());
    }
    _months = ['January','February','March','April','May','June','July','August','September',
      'October', 'November', 'December'
    ];
    _monthMap = {
      _months[0]: 1, _months[1]: 2, _months[2]: 3,
      _months[3]: 4, _months[4]: 5, _months[5]: 6,
      _months[6]: 7, _months[7]: 8, _months[8]: 9,
      _months[9]: 10, _months[10]: 11, _months[11]: 12,
    };

    for (int i = 1970; i < 2100; i++) {
      _years.add((i + 1).toString());
    }
    bloodgrps = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    currentbgrp = 'A+';
    _fullName = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _age = TextEditingController();
    _phoneNumber = TextEditingController();
    _rePass = TextEditingController();
    _ref = FirebaseDatabase.instance.reference().child('DataBase');
  }

  @override
  Widget build(BuildContext context) {
      Size _size = MediaQuery.of(context).size;
    return Scaffold(
     // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green[100],
      ),
      //backgroundColor: Colors.green[50],
      body: ListView(
        children: [Container(
          padding: EdgeInsets.only(right: 20),
          child: Stack(
            children: <Widget>[
              Container(
                  alignment: Alignment.topCenter,
                  //color: Colors.green[50],
                  padding: EdgeInsets.only(top: 40),
                  child: Text('REGISTER',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Montserrat-Thin-ttf',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ))),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('Images/ProjectTopi.png'),
                    //fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                        Colors.white.withOpacity(0.2), BlendMode.dstATop),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 100, left: 30),
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _fullNameFill,
                      child: TextFormField(
                        validator: (value){
                          if(value.isEmpty || value == null)
                            return 'Please enter some text!';
                          return null;
                        },
                        controller: _fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat-Thin.ttf',
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          labelText: 'FULL NAME',
                          hintText: 'Jon Doe',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat-Thin.ttf',
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: 3),
                    Form(
                      key: _emailFill,
                      child: TextFormField(
                        validator: (value) {
                          if (!value.contains("@")) return 'Invalid Email!';
                          if (value == null || value.isEmpty) {
                            return 'Required!';
                          }
                          return null;
                        },

                        controller: _email,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat-Thin.ttf',
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Someone@example.com',
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat-Thin.ttf',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'DATE OF BIRTH: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat-Thin.ttf',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(width: 20),
                        new DropdownButton<String>(
                          items: _days.map((String dropDownItems) {
                            return new DropdownMenuItem<String>(
                              value: dropDownItems,
                              child: new Text(dropDownItems,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat-Thin.ttf',
                                    fontWeight: FontWeight.w300,
                                  )),
                            );
                          }).toList(),
                          onChanged: (String newVal) {
                            setState(() {
                              _currentDay = newVal;
                            });
                          },
                          value: _currentDay,
                        ),
                      new  DropdownButton<String>(
                          items: _months.map((String dropDownItems) {
                            return new DropdownMenuItem<String>(
                              value: dropDownItems,
                              child: new Text(dropDownItems,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat-Thin.ttf',
                                    fontWeight: FontWeight.w300,
                                  )),
                            );
                          }).toList(),
                          onChanged: (String newVal) {
                            setState(() {
                              _currentMonth = newVal;
                            });
                          },
                          value: _currentMonth,
                        ),
                       new DropdownButton<String>(
                          items: _years.map((String dropDownItems) {
                            return new DropdownMenuItem<String>(
                              value: dropDownItems,
                              child: new Text(dropDownItems,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat-Thin.ttf',
                                    fontWeight: FontWeight.w300,
                                  )),
                            );
                          }).toList(),
                          onChanged: (String newVal) {
                            setState(() {
                              _currentYear = newVal;
                            });
                          },
                          value: _currentYear,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 9,
                          child: Form(
                            key: _passwordFill,
                            child: TextFormField(
                              validator: (value)
                              {
                                if (value == null || value.isEmpty || value.length < 6) {
                                  return 'Password should be atleast 6 characters long!';
                                }
                                return null;
                              },
                              obscureText: _obscureTextPass,
                              controller: _password,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf',
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat-Thin.ttf',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                            flex: 2,
                            child: GestureDetector(
                                onTap: () => _togglePass(),
                                child: (_obscureTextPass ? Image.asset('Images/hide.png',width: _size.width*0.2,height: _size.height*0.04,) : Image.asset('Images/show.png',width: _size.width*0.2,height: _size.height*0.04,)))
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 9,
                          child: Form(
                            key: _rePassFill,
                            child: TextFormField(
                              validator: (value){
                                if(value != _password.text)
                                  return 'Passwords don\'t match!';
                                return null;
                              },
                              obscureText: _obscureTextRePass,
                              controller: _rePass,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf',
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                labelText: 'CONFIRM PASSWORD',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat-Thin.ttf',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                            child: GestureDetector(
                                onTap: () => _toggleRePass(),
                                child: (_obscureTextRePass ? Image.asset('Images/hide.png',width: _size.width*0.2,height: _size.height*0.04,) : Image.asset('Images/show.png',width: _size.width*0.2,height: _size.height*0.04,)))
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      isExpanded: true,
                      items: bloodgrps.map((String dropDownItems) {
                        return DropdownMenuItem<String>(
                          value: dropDownItems,
                          child: Text(dropDownItems,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf',
                                fontWeight: FontWeight.w300,
                              )),
                        );
                      }).toList(),
                      onChanged: (String newVal) {
                        setState(() {
                          currentbgrp = newVal;
                        });
                      },
                      value: currentbgrp,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text('+92',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf',
                                fontWeight: FontWeight.w300,
                              )),
                        ),
                        Flexible(
                            flex: 1,
                            child: SizedBox(width: 10,)),
                        Flexible(
                          flex: 10,
                          child: Form(
                            key: _phoneNumberFill,

                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value){
                                if(value.isEmpty || value == null || value.length != 10 || double.tryParse(value) == null)
                                  return 'Invalid Phone Number!';
                                return null;
                              },
                              controller: _phoneNumber,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf',
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                labelText: 'PHONE NUMBER',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Montserrat-Thin.ttf',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                        height: 40,
                        child: Material(
                            borderRadius: BorderRadius.circular(20),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7,
                            child: InkWell(

                              onTap: (){
                                if (_emailFill.currentState.validate() &&
                                    _passwordFill.currentState.validate() && _rePassFill.currentState.validate()
                                && _phoneNumberFill.currentState.validate() && _fullNameFill.currentState.validate()) {
                                  saveInfo();
                                  _auth
                                      .createUserWithEmailAndPassword(
                                      email: _email.text,
                                      password: _password.text)
                                      .then((_) {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.bottomToTop,
                                            duration: Duration(milliseconds: 500),
                                            child: VerifyEmail()));
                                  });
                                }

                              },
                              child: Center(
                                  child: Text('Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat-Thin.tff',
                                        fontSize: 20,
                                      ))),
                            ))),
                  ],
                ),
              ),
            ],
          ),
        ),]
      )
    );
  }

  void saveInfo() async{
    String name = _fullName.text;
    String email = _email.text;
    String dob = _currentDay + ' ' + _currentMonth + ',' + _currentYear;
    String bloodType = currentbgrp;
    String age = age_calculator(int.parse(_currentDay),_monthMap[_currentMonth],int.parse(_currentYear));
    String phoneNumber = _phoneNumber.text;
    Map<String, String> info = {
      'Name': name,
      'Email': email,
      'Date Of Birth': dob,
      'Age': age,
      'Blood Type': bloodType,
      'Phone Number': '+92' + phoneNumber,
    };
    _ref.push().set(info);
  }

}
