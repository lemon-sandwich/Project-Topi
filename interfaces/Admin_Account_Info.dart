import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Admin_Interface.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'Admin_Blood_Donation.dart';
import 'Admin_Charity.dart';

class Admin_Account_Info extends StatefulWidget {
  Map info;
  Admin_Account_Info(this.info, {Key, key}) : super(key: key);
  @override
  _Admin_Account_InfoState createState() => _Admin_Account_InfoState();
}

class _Admin_Account_InfoState extends State<Admin_Account_Info> {TextEditingController name = TextEditingController();
TextEditingController bloodType = TextEditingController();
TextEditingController age = TextEditingController();
String _age;
bool _colorHome = false;
bool _colorCharity = false;
bool emptyName = false;
bool emptyBGRP = false;
bool emptyAge = false;
bool _colorBloodDonations = false;
final _nameChange = GlobalKey<FormState>();
final _bloodTypeChange = GlobalKey<FormState>();
final _ageChange = GlobalKey<FormState>();
bool _colorAccountInfo = true;
FirebaseAuth _auth = FirebaseAuth.instance;
final databaseReference = FirebaseDatabase.instance.reference();
bool editName = false;
bool editBloodType = false;
bool editAge = false;
final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
User _user;
List<String> _days = ['1'];
var _currentDay = DateTime.now().day.toString();
List<String> _months;
var _currentMonth;
List<String> _years = ['1970'];
var _currentYear = DateTime.now().year.toString();
DateTime _date;
var _monthMap;
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
  _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  _monthMap = {
    _months[0]: 1,
    _months[1]: 2,
    _months[2]: 3,
    _months[3]: 4,
    _months[4]: 5,
    _months[5]: 6,
    _months[6]: 7,
    _months[7]: 8,
    _months[8]: 9,
    _months[9]: 10,
    _months[10]: 11,
    _months[11]: 12,
  };

  for (int i = 1970; i < 2100; i++) {
    _years.add((i + 1).toString());
  }
  _user = _auth.currentUser;
}

@override
  Widget build(BuildContext context) {
  child:
  Text(widget.info.toString());
  if(widget.info['Name'] == 'N/A')
    editName = true;
  if(widget.info['Blood Type'] == 'N/A')
    editBloodType = true;
  if(widget.info['Age'] == 'N/A')
    editAge = true;

  Size _size = MediaQuery.of(context).size;
  return WillPopScope(
    onWillPop: () async => false,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: _size.height * 0.2, horizontal: _size.width * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('NAME',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  )),
              SizedBox(
                width: 40,
              ),
              editName
                  ? Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Form(
                      key: _nameChange,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter a name';
                          return null;
                        },
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
                            if (_nameChange.currentState.validate()) {
                              String result;
                              databaseReference
                                  .once()
                                  .then((DataSnapshot snapshot) {
                                Map<dynamic, dynamic> values =
                                snapshot.value['DataBase'];
                                for (var key in values.values) {
                                  if (key['Email'] ==
                                      _auth.currentUser.email) {
                                    MapEntry entry = values.entries
                                        .firstWhere(
                                            (element) =>
                                        element.value == key,
                                        orElse: () => null);
                                    result = entry.toString().substring(
                                        entry.toString().indexOf('(') + 1,
                                        entry.toString().indexOf(':'));
                                    databaseReference
                                        .child('DataBase')
                                        .child(result)
                                        .update({'Name': name.text});
                                    break;
                                  }
                                }
                              });
                              widget.info.update('Name', (value) {
                                return name.text;
                              });
                              setState(() {
                                editName = false;
                              });
                            }
                          },
                          child: Image.asset(
                            'Images/check.png',
                            height: _size.height * 0.03,
                          )))
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.info['Name'].toString(),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        letterSpacing: 2,
                        fontSize: 20,
                      )),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          editName = true;
                        });
                      },
                      child: Image.asset(
                        'Images/edit.png',
                        height: _size.height * 0.03,
                      )),
                ],
              ),
              SizedBox(height: 20),
              Text('BLOOD GROUP',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  )),
              SizedBox(height: 8),
              editBloodType
                  ? Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Form(
                      key: _bloodTypeChange,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a Blood Type!';
                          } else if (!bloodGroups.contains(value))
                            return 'Invalid Blood Type!';
                          return null;
                        },
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
                            if (_bloodTypeChange.currentState
                                .validate()) {
                              String result;
                              databaseReference
                                  .once()
                                  .then((DataSnapshot snapshot) {
                                Map<dynamic, dynamic> values =
                                snapshot.value['DataBase'];
                                for (var key in values.values) {
                                  if (key['Email'] ==
                                      _auth.currentUser.email) {
                                    MapEntry entry = values.entries
                                        .firstWhere(
                                            (element) =>
                                        element.value == key,
                                        orElse: () => null);
                                    result = entry.toString().substring(
                                        entry.toString().indexOf('(') + 1,
                                        entry.toString().indexOf(':'));
                                    databaseReference
                                        .child('DataBase')
                                        .child(result)
                                        .update({
                                      'Blood Type': bloodType.text
                                    });
                                    break;
                                  }
                                }
                              });
                              widget.info.update('Blood Type', (value) {
                                return bloodType.text;
                              });
                              setState(() {
                                editBloodType = false;
                              });
                            }
                          },
                          child: Image.asset(
                            'Images/check.png',
                            height: _size.height * 0.03,
                          )))
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.info['Blood Type'].toString(),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        letterSpacing: 2,
                        fontSize: 20,
                      )),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          editBloodType = true;
                        });
                      },
                      child: Image.asset(
                        'Images/edit.png',
                        height: _size.height * 0.03,
                      )),
                ],
              ),
              SizedBox(height: 20),
              Text('AGE',
                  style: TextStyle(
                    color: Colors.grey[500],
                    letterSpacing: 2,
                  )),
              SizedBox(height: 8),
              editAge // EDIT AGE
                  ? Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: Form(
                      key: _ageChange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
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
                          new DropdownButton<String>(
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
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: TextButton(
                          onPressed: () {
                            if (_ageChange.currentState.validate()) {
                              String result;
                              _age = age_calculator(
                                  int.parse(_currentDay),
                                  _monthMap[_currentMonth],
                                  int.parse(_currentYear));
                              databaseReference
                                  .once()
                                  .then((DataSnapshot snapshot) {
                                Map<dynamic, dynamic> values =
                                snapshot.value['DataBase'];
                                for (var key in values.values) {
                                  if (key['Email'] ==
                                      _auth.currentUser.email) {
                                    MapEntry entry = values.entries
                                        .firstWhere(
                                            (element) =>
                                        element.value == key,
                                        orElse: () => null);
                                    result = entry.toString().substring(
                                        entry.toString().indexOf('(') + 1,
                                        entry.toString().indexOf(':'));
                                    databaseReference
                                        .child('DataBase')
                                        .child(result)
                                        .update({
                                      'Age': _age,
                                      'Date Of Birth': _currentDay +
                                          ' ' +
                                          _currentMonth +
                                          ',' +
                                          _currentYear,
                                    });
                                    break;
                                  }
                                }
                              });
                              widget.info.update('Age', (value) {
                                return _age;
                              });
                              widget.info.update('Date Of Birth',
                                      (value) {
                                    return _currentDay +
                                        ' ' +
                                        _currentMonth +
                                        ',' +
                                        _currentYear;
                                  });
                              setState(() {
                                editAge = false;
                              });
                            }
                          },
                          child: Image.asset(
                            'Images/check.png',
                            height: _size.height * 0.03,
                          )))
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.info['Age'].toString(),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        letterSpacing: 2,
                        fontSize: 20,
                      )),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          editAge = true;
                        });
                      },
                      child: Image.asset(
                        'Images/edit.png',
                        height: _size.height * 0.03,
                      )),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(height: 150),
              InkWell(
                  onTap: () => _auth.signOut().then((_) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }),
                  child: Row(
                    children: [
                      Text('Logout',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Montserrat-Thin.tff',
                            fontSize: 20,
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Image(
                          image: AssetImage(
                            'Images/signout.png',
                          ),
                          height: _size.height * 0.03,
                          color: Colors.blueAccent),
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
                    height: _size.height * 0.057,
                    minWidth: _size.width * 0.25,
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
                            child: Admin_Interface(),
                          ));
                    },
                    child: Image.asset(
                      'Images/home.png',
                      height: _size.height * 0.04,
                      color: Colors.blueAccent,
                    ),
                  ),
                  FlatButton(
                    height: _size.height * 0.057,
                    minWidth: _size.width * 0.25,
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
                            child: Admin_Charity(),
                          ));
                    },
                    child: Image.asset(
                      'Images/charity.png',
                      height: _size.height * 0.04,
                    ),
                  ),
                  FlatButton(
                    height: _size.height * 0.057,
                    minWidth: _size.width * 0.25,
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
                            child: Admin_Blood_Donation(),
                          ));
                    },
                    child: Image(
                      image: AssetImage('Images/blood_donation_color.png'),
                      height: _size.height * 0.04,
                    ),
                  ),
                  FlatButton(
                    height: _size.height * 0.057,
                    minWidth: _size.width * 0.25,
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
                    child: Image.asset(
                      'Images/account_circle.png',
                      height: _size.height * 0.04,
                      color: Colors.blue,
                    ),
                  ),
                ]),
          ],
        ),
      ]),
    ),
  );
}
}
