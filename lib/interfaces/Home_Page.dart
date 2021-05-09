import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/interfaces/Loading_Screen.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'Create_Post_v2.dart';

class Home_Page extends StatefulWidget {
  bool _admin;
  Home_Page(this._admin, {Key, key}) : super(key: key);
  @override
  _Home_PageState createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  bool _is_home_page = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animationIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  bool _colorHome = true;
  bool _colorCharity = false;
  bool _colorBloodDonations = false;
  bool _colorAccountInfo = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  Map info;
  Map _posts;
  int total_posts = 0;
  bool empty = false;
  //List<Widget> Cards = NumberOfCards(total_posts);
  List<Widget> Cards = [SizedBox(height: 0,)];
  void readData() {
    databaseReference.once().then((DataSnapshot snapshot) {
      total_posts = 0;

      // DATABASE USER INFORMATION

      Map<dynamic, dynamic> values = snapshot.value['DataBase'];
      for (var key in values.values) {
        if (key['Email'] == _auth.currentUser.email) {
          info = {
            'Name': key['Name'],
            'Email': key['Email'],
            'Date Of Birth': key['Date Of Birth'],
            'Age': key['Age'],
            'Phone Number': key['Phone Number'],
            'Blood Type': key['Blood Type'],
          };
          break;
        }
      }

      //  DATABASE GATHER ALL POSTS

      Cards = [SizedBox(height: 0,)];
      values = snapshot.value['Posts'];
      if(values == null)
        {
          empty = true;
          print('No Post Made Yet');
        }
      else {
        for (var key in values.values) {
          _posts = {
              'Title': key['Title'],
              'Amount': key['Amount'],
              'Description': key['Description'],
              'Donation Type': key['Donation Type'],
          };
          total_posts++;
          Cards.add(Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      _posts['Title'],
                      style: TextStyle(
                        fontFamily: 'Montserrat-Light.tff',
                        fontSize: 20,
                        color: Colors.pink,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(
                          'DESCRIPTION: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.orange,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          _posts['Description'],
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(
                          'AMOUNT: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.orange,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          _posts['Amount'],
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(
                          'DONATION TYPE: ',
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            color: Colors.orange,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          _posts['Donation Type'],
                          style: TextStyle(
                            fontFamily: 'Montserrat-Light.tff',
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'DONATE',
                              style: TextStyle(
                                fontFamily: 'Montserrat-Light.tff',
                                fontSize: 15,
                              ),
                            ),
                          ),),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )));
        }
      }
    });
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  TextEditingController name = TextEditingController();
  TextEditingController bloodType = TextEditingController();
  TextEditingController age = TextEditingController();
  String _age;
  final _nameChange = GlobalKey<FormState>();
  final _bloodTypeChange = GlobalKey<FormState>();
  final _ageChange = GlobalKey<FormState>();
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
  String age_calculator(int day, int month, int year) {
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
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {});
          });
    _animationIcon =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _buttonColor = ColorTween(begin: Colors.blueAccent, end: Colors.red)
        .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(0, 1, curve: Curves.linear)));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Interval(0, 0.75, curve: _curve)));
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
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      readData();
      if (info != null) {
        print('INFO NOT NULL');
        if(empty)
            print('POSTS ARE EMPTY');
        else if(_posts != null)
          print('POSTS NOT NULL');
        timer.cancel();

        setState(() {
          _show = true;
          _home_show = true;
        });
      }
    });
  }

  Widget buttonAdd() {
    return Container(
      child: FloatingActionButton(
        heroTag: "Button1",
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: Duration(milliseconds: 500),
                child: Create_Post_v2(empty),
              ));
        },
        tooltip: 'Add',
        child: Image.asset(
          'Images/plus.png',
          color: Colors.white,
          height: 20,
        ),
      ),
    );
  }

  Widget buttonEdit() {
    return Container(
      child: FloatingActionButton(
        heroTag: "Button2",
        onPressed: () {},
        tooltip: 'Edit',
        child: Image.asset(
          'Images/edit.png',
          color: Colors.white,
          height: 20,
        ),
      ),
    );
  }

  Widget buttonDelete() {
    return Container(
      child: FloatingActionButton(
        heroTag: "Button3",
        onPressed: () {},
        tooltip: 'Delete',
        child: Image.asset(
          'Images/delete.png',
          color: Colors.white,
          height: 20,
        ),
      ),
    );
  }

  Widget buttonToggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: "Button4",
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animationIcon,
        ),
      ),
    );
  }

  animate() {
    // setState(() {
    if (!isOpened)
      _animationController.forward();
    else
      _animationController.reverse();
    isOpened = !isOpened;
    //  });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  bool _show = false;
  bool _home_show = false;

  @override
  Widget build(BuildContext context) {
    child:
    Text(widget._admin.toString());
    Size _size = MediaQuery.of(context).size;
    List _widgetOptions = [
      _home_show
          ? Scaffold(
              backgroundColor: Colors.grey[200],
              body: Padding(
                  padding: EdgeInsets.fromLTRB(10, _size.height * 0.08, 10, 0),
                  child: new ListView.builder(
                  itemCount: Cards.length,
                  itemBuilder: (BuildContext context,int index) => Cards.elementAt(index)
                  )
              ),
            )
          : Loading_Screen(),
      Center(
        child: Text('Charity',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
      Center(
        child: Text('Blood Donation',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
      _show
          ? WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.grey[200],
                body: ListView(
                  children: [
                    Stack(children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: _size.height * 0.2,
                            horizontal: _size.width * 0.1),
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
                                              if (value == null ||
                                                  value.isEmpty)
                                                return 'Enter a name';
                                              return null;
                                            },
                                            controller: name,
                                            decoration: InputDecoration(
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelText: 'FULL NAME',
                                              labelStyle: TextStyle(
                                                fontFamily:
                                                    'Montserrat-Light.tff',
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
                                                if (_nameChange.currentState
                                                    .validate()) {
                                                  String result;
                                                  databaseReference.once().then(
                                                      (DataSnapshot snapshot) {
                                                    Map<dynamic, dynamic>
                                                        values = snapshot
                                                            .value['DataBase'];
                                                    for (var key
                                                        in values.values) {
                                                      if (key['Email'] ==
                                                          _auth.currentUser
                                                              .email) {
                                                        MapEntry entry = values
                                                            .entries
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .value ==
                                                                    key,
                                                                orElse: () =>
                                                                    null);
                                                        result = entry
                                                            .toString()
                                                            .substring(
                                                                entry
                                                                        .toString()
                                                                        .indexOf(
                                                                            '(') +
                                                                    1,
                                                                entry
                                                                    .toString()
                                                                    .indexOf(
                                                                        ':'));
                                                        databaseReference
                                                            .child('DataBase')
                                                            .child(result)
                                                            .update({
                                                          'Name': name.text
                                                        });
                                                        break;
                                                      }
                                                    }
                                                  });
                                                  info.update('Name', (value) {
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(info['Name'].toString(),
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
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Enter a Blood Type!';
                                              } else if (!bloodGroups
                                                  .contains(value))
                                                return 'Invalid Blood Type!';
                                              return null;
                                            },
                                            controller: bloodType,
                                            decoration: InputDecoration(
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelText: 'BLOOD TYPE',
                                              labelStyle: TextStyle(
                                                fontFamily:
                                                    'Montserrat-Light.tff',
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
                                                if (_bloodTypeChange
                                                    .currentState
                                                    .validate()) {
                                                  String result;
                                                  databaseReference.once().then(
                                                      (DataSnapshot snapshot) {
                                                    Map<dynamic, dynamic>
                                                        values = snapshot
                                                            .value['DataBase'];
                                                    for (var key
                                                        in values.values) {
                                                      if (key['Email'] ==
                                                          _auth.currentUser
                                                              .email) {
                                                        MapEntry entry = values
                                                            .entries
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .value ==
                                                                    key,
                                                                orElse: () =>
                                                                    null);
                                                        result = entry
                                                            .toString()
                                                            .substring(
                                                                entry
                                                                        .toString()
                                                                        .indexOf(
                                                                            '(') +
                                                                    1,
                                                                entry
                                                                    .toString()
                                                                    .indexOf(
                                                                        ':'));
                                                        databaseReference
                                                            .child('DataBase')
                                                            .child(result)
                                                            .update({
                                                          'Blood Type':
                                                              bloodType.text
                                                        });
                                                        break;
                                                      }
                                                    }
                                                  });
                                                  info.update('Blood Type',
                                                      (value) {
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(info['Blood Type'].toString(),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              new DropdownButton<String>(
                                                items: _days.map(
                                                    (String dropDownItems) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: dropDownItems,
                                                    child: new Text(
                                                        dropDownItems,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat-Thin.ttf',
                                                          fontWeight:
                                                              FontWeight.w300,
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
                                                items: _months.map(
                                                    (String dropDownItems) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: dropDownItems,
                                                    child: new Text(
                                                        dropDownItems,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat-Thin.ttf',
                                                          fontWeight:
                                                              FontWeight.w300,
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
                                                items: _years.map(
                                                    (String dropDownItems) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: dropDownItems,
                                                    child: new Text(
                                                        dropDownItems,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'Montserrat-Thin.ttf',
                                                          fontWeight:
                                                              FontWeight.w300,
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
                                                if (_ageChange.currentState
                                                    .validate()) {
                                                  String result;
                                                  _age = age_calculator(
                                                      int.parse(_currentDay),
                                                      _monthMap[_currentMonth],
                                                      int.parse(_currentYear));
                                                  databaseReference.once().then(
                                                      (DataSnapshot snapshot) {
                                                    Map<dynamic, dynamic>
                                                        values = snapshot
                                                            .value['DataBase'];
                                                    for (var key
                                                        in values.values) {
                                                      if (key['Email'] ==
                                                          _auth.currentUser
                                                              .email) {
                                                        MapEntry entry = values
                                                            .entries
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .value ==
                                                                    key,
                                                                orElse: () =>
                                                                    null);
                                                        result = entry
                                                            .toString()
                                                            .substring(
                                                                entry
                                                                        .toString()
                                                                        .indexOf(
                                                                            '(') +
                                                                    1,
                                                                entry
                                                                    .toString()
                                                                    .indexOf(
                                                                        ':'));
                                                        databaseReference
                                                            .child('DataBase')
                                                            .child(result)
                                                            .update({
                                                          'Age': _age,
                                                          'Date Of Birth':
                                                              _currentDay +
                                                                  ' ' +
                                                                  _currentMonth +
                                                                  ',' +
                                                                  _currentYear,
                                                        });
                                                        break;
                                                      }
                                                    }
                                                  });
                                                  info.update('Age', (value) {
                                                    return _age;
                                                  });
                                                  info.update('Date Of Birth',
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(info['Age'].toString(),
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
                                      Navigator.pop(context);
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
                    ]),
                  ],
                ),
              ),
            )
          : Loading_Screen()
    ];
    if (_selectedIndex == 0)
      _is_home_page = true;
    else
      _is_home_page = false;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: _widgetOptions.elementAt(_selectedIndex),
          floatingActionButton: Opacity(
            opacity: widget._admin && _is_home_page ? 1 : 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Transform(
                  transform: Matrix4.translationValues(
                      0, _translateButton.value * 3.0, 0),
                  child: buttonAdd(),
                ),
                Transform(
                  transform: Matrix4.translationValues(
                      0, _translateButton.value * 2.0, 0),
                  child: buttonEdit(),
                ),
                Transform(
                  transform:
                      Matrix4.translationValues(0, _translateButton.value, 0),
                  child: buttonDelete(),
                ),
                buttonToggle(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.greenAccent,
            type: BottomNavigationBarType.shifting,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: new Image.asset('Images/home.png',
                    height: _size.height * 0.02, color: Colors.blueAccent),
                title: new Text(
                  'Home',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              BottomNavigationBarItem(
                icon: new Image.asset(
                  'Images/charity.png',
                  height: _size.height * 0.03,
                ),
                title: new Text(
                  'Charity',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    'Images/blood_donation_color.png',
                    height: _size.height * 0.03,
                  ),
                  title: Text(
                    'Blood Donation',
                    style: TextStyle(color: Colors.blueAccent),
                  )),
              BottomNavigationBarItem(
                icon: Image.asset('Images/account_circle.png',
                    height: _size.height * 0.03, color: Colors.blueAccent),
                title: Text(
                  'Account',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            ],
          ),
        ));
  }
}
