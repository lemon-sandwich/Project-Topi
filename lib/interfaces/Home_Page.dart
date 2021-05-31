import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/interfaces/Loading_Screen.dart';
import 'package:flutter_app/interfaces/Post_Info.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'Create_Notification.dart';
import 'Create_Post_v2.dart';
import 'Donate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'NewScreen.dart';

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
  bool is_notification_page = false;
  bool editName = false;
  bool editBloodType = false;
  bool editAge = false;
  bool edit_delete = false;
  bool posts_retrieved = false;
  bool notifs = false;
  bool fill = false;
  bool notif_sent = false;
  bool _changes_made = false;
  bool _show = false;
  bool _home_show = false;
  bool done = false;

  final _nameChange = GlobalKey<FormState>();
  final _bloodTypeChange = GlobalKey<FormState>();
  final _ageChange = GlobalKey<FormState>();

  var _currentDay = DateTime.now().day.toString();
  var _currentMonth;
  var _currentYear = DateTime.now().year.toString();
  var _monthMap;

  Map info;
  Map _posts;
  Map notifications;

  List<Map> all_posts = [];
  List<Map> all_notifications = [];

  String result;
  String entry;
  String user_name;
  String _age;
  String _msg_title, _msg_body;

  List<String> _days = ['1'];
  List<String> _months;
  List<String> _years = ['1970'];

  int posts_loaded = 0;
  int _selectedIndex = 0;
  int _card_counter = 0;
  int _total_posts = -1;
  int _new_posts = 0;

  List<Widget> Notif_Cards = [
    SizedBox(
      height: 0,
    )
  ];
  List<Widget> Cards = [
    SizedBox(
      height: 0,
    )
  ];

  TextEditingController name = TextEditingController();
  TextEditingController bloodType = TextEditingController();
  TextEditingController age = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  final databaseReference = FirebaseDatabase.instance.reference();
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  DateTime _date;

  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      _msg_title = event.notification.title;
      _msg_body = event.notification.body;
      setState(() {
        fill = true;
        notif_sent = true;
      });
      print(event.notification.body);
      if (_selectedIndex != 1)
        showNotification(_msg_title, _msg_body);
    });

    readData();
    readData_posts();
    readData_notifications();
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
    if (_changes_made) readData_posts();
    if (notif_sent || filled()) readData_notifications();
    Size _size = MediaQuery.of(context).size;
    List _widgetOptions = [
      _home_show
          ? Scaffold(
              backgroundColor: Colors.grey[200],
              body: Padding(
                padding: EdgeInsets.fromLTRB(10, _size.height * 0.08, 10, 0),
                child: new ListView.builder(
                  itemCount: Cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                duration: Duration(milliseconds: 500),
                                child: Post_Info(
                                    all_posts[index - 1],
                                    widget
                                        ._admin), // index - 1 because I added a SizedBox of height 0 as a starter of the List
                              )).then((_) {
                            setState(() {
                              _changes_made = true;
                            });
                          });
                        },
                        child: Cards.elementAt(index));
                  },
                ),
              ),
            )
          : Loading_Screen(),
      notifs
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsets.fromLTRB(10, _size.height * 0.08, 10, 0),
                child: new ListView.builder(
                  itemCount: Notif_Cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("INDEX NUMBER: " + index.toString());
                    final item = Notif_Cards[index];
                    return Dismissible(
                      child: Notif_Cards.elementAt(index),
                      direction: DismissDirection.horizontal,
                      key: Key(item.toStringShort()),
                      background: Card(
                        color: Colors.red,
                        margin: EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          print(index);
                          print(Notif_Cards);
                          Notif_Cards.removeAt(index);
                          print(all_notifications[index - 1]);
                          // if i dismiss a notif, the one above gets dismissed instead
                          FirebaseDatabase.instance
                              .reference()
                              .child('DataBase')
                              .child(user_name)
                              .child('Notifications')
                              .child(all_notifications[index - 1]['Hash'])
                              .remove();
                          notif_sent = true;
                          all_notifications.remove(index - 1);
                        });
                      },
                    );
                  },
                ),
              ),
            )
          : Loading_Screen(),
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
                                                fontFamily: 'Montserrat',
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
                                                fontFamily: 'Montserrat',
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
                                                              'Montserrat',
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
                                                              'Montserrat',
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
                                                              'Montserrat',
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
                                          fontFamily: 'Montserrat',
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
    if (_selectedIndex == 1)
      is_notification_page = true;
    else
      is_notification_page = false;

    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: _widgetOptions.elementAt(_selectedIndex),
          floatingActionButton: Opacity(
            opacity: widget._admin && _is_home_page
                ? 1
                : 0,
            child: FloatingActionButton(
              heroTag: "Add Post",
              onPressed: () async {
                if (widget._admin) {
                  if (_selectedIndex == 0) {
                    await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          duration: Duration(milliseconds: 500),
                          child: Create_Post_v2(),
                        )).then((_) {
                      int counter = -1;
                      databaseReference.once().then((DataSnapshot snapshot) {
                        Map<dynamic, dynamic> values = snapshot.value['Posts'];
                        for (var key in values.values) {
                          counter++;
                        }
                      }).then((_) {
                        if (_total_posts < counter)
                          setState(() {
                            posts_retrieved = false;
                            _changes_made = true;
                            _total_posts = counter;
                          });
                        databaseReference
                            .child('Posts')
                            .child('Total Posts')
                            .update({
                          'Total Posts': counter,
                        });
                      });
                    });
                  }
                }
              },
              tooltip:'New Post',
              child: Image.asset(
                'Images/plus.png',
                color: Colors.white,
                height: 20,
              ),
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

  void readData() {
    setState(() {
      _show = false;
    });

    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      // DATABASE USER INFORMATION
      Map<dynamic, dynamic> values = snapshot.value['DataBase'];
      for (var key in values.values) {
        if (key['Email'] == _auth.currentUser.email) {
          info = {
            'Name': key['Name'],
            'Email': key['Email'],
            'Date Of Birth': key['Date Of Birth'],
            'Age': key['Age'],
            'Password': key['Password'],
            'Phone Number': key['Phone Number'],
            'Blood Type': key['Blood Type'],
          };
          setState(() {
            _show = true;
          });
          break;
        }
      }
    });
  }

  void readData_posts() {
    setState(() {
      _home_show = false;
      posts_retrieved = false;
      _changes_made = false;
      _total_posts = -1;
      posts_loaded = 0;
      Cards = [
        SizedBox(
          height: 0,
        )
      ];
    });
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value['Posts'];
      all_posts = [];

      if (values == null) {
        print('No Post Made Yet');
        databaseReference
            .child('Posts')
            .child('Total Posts')
            .set({'Total Posts': 0});
        setState(() {
          _home_show = true;
        });
      } else {
        databaseReference
            .child('Posts')
            .child('Total Posts')
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            _total_posts = snapshot.value['Total Posts'];
            print('Total Posts: ' + _total_posts.toString());
          });
        }).then((_) {
          if (_total_posts != 0) {
            for (var key in values.values) {
              if (key['Total Posts'] == null) {
                var reversed = Map.fromEntries(values.entries
                    .map((e) => MapEntry(e.value, e.key))); // To get the hash
                _posts = {
                  'Title': key['Title'],
                  'Amount': key['Amount'],
                  'Description': key['Description'],
                  'Donation Type': key['Donation Type'],
                  'Hash': reversed[key],
                  'Image URL': key['Image URL']
                };
                setState(() {
                  posts_loaded++;
                  all_posts.add(_posts);
                  Cards.add(Card(
                      elevation: 10,
                      margin: EdgeInsets.only(bottom: 10),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: Colors.grey[800],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 10,
                            margin: EdgeInsets.only(bottom: 10),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: Colors.orange,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _posts['Title'],
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${_posts['Amount']}/-',
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'DESCRIPTION: ',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _posts['Description'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  'DONATION TYPE: ',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
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
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _posts['Image URL'] == 'N/A'
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No Image Attached'.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'Images/paperclip.png',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Image Attached'.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print('Pressed');
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        duration: Duration(milliseconds: 500),
                                        child: Donate(),
                                      ));
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'DONATE',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      )));
                  print("Posts Loaded: " + posts_loaded.toString());
                  if (posts_loaded == _total_posts) {
                    print('Posts loaded = Total posts');
                    posts_retrieved = true;
                    _home_show = true;
                  }
                });
              }
              if (posts_retrieved) {
                setState(() {
                  _changes_made = false;
                });

                break;
              }
            }
          } else {
            setState(() {
              _home_show = true;
              _changes_made = false;
            });
          }
        });
      }
    });
  }

  void readData_notifications() {
    setState(() {
      notifs = false;
      notif_sent = false;
      _card_counter = 0;
      Notif_Cards = [
        SizedBox(
          height: 0,
        )
      ];
      all_notifications = [];
    });
    print('Reading');
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.once().then((DataSnapshot snapshot) {
      // DATABASE USER INFORMATION
      Map<dynamic, dynamic> values = snapshot.value['DataBase'];
      print('Reading');
      if (values != null)
        for (var key in values.values) {
          if (key['Email'] == _auth.currentUser.email) {
            user_name = key['Name'];
            values = snapshot.value['DataBase'][key['Name']]['Notifications'];
            print('Reading');
            break;
          }
        }
      if (values != null) {
        for (var key in values.values) {
          var reversed = Map.fromEntries(
              values.entries.map((e) => MapEntry(e.value, e.key)));
          print('Reading');
          notifications = {
            'Title': key['Title'],
            'Body': key['Body'],
            'Hash': reversed[key]
          };
          all_notifications.add(notifications);
          Notif_Cards.add(Card(
              elevation: 7,
              margin: EdgeInsets.only(bottom: 10),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.grey[800],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                    child: Row(
                      children: [
                        Image.asset(
                          'Images/ProjectTopi.png',
                          height: MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.width * 0.04,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            '${notifications['Title']}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Flexible(
                      child: Text(
                        notifications['Body'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              )));
          _card_counter++;
        }
      }
      setState(() {
        print('ALL NOTIFICATIONS =>');
        print(all_notifications);
        notifs = true;
      });
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _changes_made = false;
        readData_posts();
      }
    });
  }

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
}
