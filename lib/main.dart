//import 'dart:convert';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Home_Page.dart';
import 'package:flutter_app/interfaces/Forgot_Password.dart';
import 'package:hexcolor/hexcolor.dart';
import 'interfaces/NewScreen.dart';
import 'interfaces/Signup_interface.dart';
import 'services/facebooklogin.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool _fill = false;
bool _pushed = false;
bool filled() {
  if(_pushed == true) {
    return true;
  } else return false;
}
void push_notifications(String title,String body) {
  _fill = false;
  print('Notification Pushed');
  DatabaseReference _ref = FirebaseDatabase.instance.reference();
  _ref.once().then((DataSnapshot snapshot) {
    Map values = snapshot.value['DataBase'];
    print("Keys: " + values.keys.toString());
    for (int index = 0; index < values.keys.length; index++) {
      _ref = FirebaseDatabase.instance
          .reference()
          .child('DataBase')
          .child(values.keys.elementAt(index))
          .child('Notifications');
      _ref.push().set({
        'Title': title,
        'Body': body,
      });
    }
  });
  _pushed = true;
  filled();
  Timer.periodic(Duration(milliseconds: 50) , (timer) {
    _pushed = false;
    timer.cancel();
  });
}
var initializationSettingsAndroid =
AndroidInitializationSettings('@mipmap/ic_launcher');
var initializationSettingsIOs = IOSInitializationSettings();
var initSetttings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
showNotification(String title,String description) async {
  var android = new AndroidNotificationDetails(
      'id', 'channel ', 'description',
      priority: Priority.high, importance: Importance.max);
  var iOS = new IOSNotificationDetails();
  var platform = new NotificationDetails(android: android, iOS: iOS);
  await flutterLocalNotificationsPlugin.show(
      0, title, description, platform,
      payload: 'Welcome to the Local Notification demo ');
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  showNotification(message.notification.title, message.notification.body);
  DatabaseReference _ref =
  FirebaseDatabase.instance.reference();
  _ref.once().then((DataSnapshot snapshot) {
    Map values = snapshot.value['DataBase'];
    print("Keys: " + values.keys.toString());
    for(int index=0;index<values.keys.length;index++)
    {
      print(values.keys.elementAt(index));
      _ref =
          FirebaseDatabase.instance.reference().child('DataBase').child(values.keys.elementAt(index)).child('Notifications');
      _ref.push().set({
        'Title': message.notification.title,
        'Body': message.notification.body,
      });
    }
  });
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {



  Future<void> Messaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await FirebaseMessaging.instance.subscribeToTopic('BloodDonations');
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    String token = await messaging.getToken(
      vapidKey:
      "eHQGWU1lR0Wg3nHREIycqo:APA91bENbRGQ8qz6--GZ6eV_3h61aWKbQojomZn7ySJWE9m-z0SRRyiVGovrZR0MvainBth82QySlF-5a7E5r8akfHe8LJdRXQO1iR4m9BAQvhxhet17K4T_eLD-M8gQBktYp67FnEaG",
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }


  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  final _email_fill = GlobalKey<FormState>();
  final _password_fill = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _ref = FirebaseDatabase.instance.reference();
  Map _data;
  bool _obscureTextPass = true;
  bool _inside = false;
  @override
  void _togglePass() {
    setState(() {
      _obscureTextPass = !_obscureTextPass;
    });
  }
  String _msg_title,_msg_body;

  @override
  void initState() {
    // TODO: implement initState
    Messaging();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      showNotification(event.notification.title, event.notification.body);
      print("message recieved");
      _msg_title = event.notification.title;
      _msg_body = event.notification.body;
      setState(() {
        _fill = true;
        filled();
      });
      print("main():=> Description: " + event.notification.body);
    });
    if(_fill && !_inside) push_notifications(_msg_title,_msg_body);
    _ref.once().then((DataSnapshot snapshot) {
      _data = snapshot.value['DataBase'];
    });
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      //resizeToAvoidBottomInset: false,
      body: ListView(children: [
        Stack(children: <Widget>[
          Container(
            height: _size.height,
            width: _size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'Images/ProjectTopi.png',
                ),
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
                          fontFamily: 'Montserrat',
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
                          fontFamily: 'Montserrat',
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
                      key: _email_fill,
                      child: TextFormField(
                        validator: (value) {
                          bool found = false;
                          if (!value.contains("@")) return 'Invalid Email!';
                          for(var key in _data.values)
                            if(key['Email'] == value)
                              found = true;
                            if(!found)
                              return 'Not SignedUp Yet!';
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: _email,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 10,
                          child: Form(
                            key: _password_fill,
                            child: TextFormField(
                              validator: (value) {
                                bool found = false;
                                for(var key in _data.values)
                                  if(key['Password'] == value)
                                    found = true;
                                if(!found)
                                  return 'Wrong Password!';
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              controller: _password,
                              obscureText: _obscureTextPass,
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: 'PASSWORD',
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
                            flex: 1,
                            child: GestureDetector(
                                onTap: () => _togglePass(),
                                child: (_obscureTextPass
                                    ? Image.asset(
                                        'Images/hide.png',
                                        width: 30,
                                        height: 30,
                                      )
                                    : Image.asset(
                                        'Images/show.png',
                                        width: 30,
                                        height: 30,
                                      )))),
                      ],
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
                              fontFamily: 'Montserrat'),
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
                              if (_email_fill.currentState.validate() &&
                                  _password_fill.currentState.validate()) {
                                dynamic result = await _auth
                                    .signInWithEmailAndPassword(
                                        email: _email.text,
                                        password: _password.text)
                                    .then((_) {
                                      bool _admin= false;
                                  if (_email.text == 'waseyu7119@gmail.com' &&
                                      _password.text == 'dC.l9h8J(\'')
                                    _admin = true;
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            duration:
                                                Duration(milliseconds: 500),
                                            child: Home_Page(_admin)));
                                }).catchError((e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Invalid Email or Password')));
                                });
                              }
                            },
                            child: Center(
                                child: Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
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
                                            type:
                                                PageTransitionType.bottomToTop,
                                            duration:
                                                Duration(milliseconds: 500),
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
                                            fontFamily: 'Montserrat'),
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
                            fontFamily: 'Montserrat',
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
      ]),
    );
  }
}
