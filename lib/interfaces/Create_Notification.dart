import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'NewScreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
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
  print("Handling a background message: ${message.notification.body}");
}

class Create_Notification extends StatefulWidget {
  @override
  _Create_NotificationState createState() => _Create_NotificationState();
}

class _Create_NotificationState extends State<Create_Notification> {
  TextEditingController _notification_title = TextEditingController();
  TextEditingController _notification_description = TextEditingController();
  final _title = GlobalKey<FormState>();
  final _description = GlobalKey<FormState>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Future onSelectNotification(String payload) {
    print('Selected!');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  @override
  void initState() {

    // TODO: implement initState
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    FlutterLocalNotificationsPlugin().initialize(initSetttings,
        onSelectNotification: onSelectNotification);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    Notification_plugin() async {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      print('Done');
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    FirebaseMessaging.instance.sendMessage(
      to: 'AAAANoHJbaQ:APA91bFgF8rDWMF8jkt6sUQHiGtmkjIXsSzLp5pti-kNYsORt_O_qcmfVqoYtLZ7zvnP6bMX62DEfWnWWHroMypbLffI_WP55Lc4cUso5-kKgB0gylpZDO0TGxHGj44MFyfH6JJPD55J',
      data: {
        'Title': 'Hello',
        'Body': 'World'
      }
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _firebaseMessagingBackgroundHandler(message);
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      print('ForeGround MSG');
      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
                // other properties...
              ),
            ));
      }
    });
    Notification_plugin();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.transparent, //change your color here
        ),
        backgroundColor: Colors.orange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                if(_title.currentState.validate() && _description.currentState.validate()) {
                  {
                    showNotification();
                  }
                }
              },
              child: Text('SEND',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  )),
            )
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _title,
              child: TextFormField(
                maxLength: 50,
                maxLines: 2,
                controller: _notification_title,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Required!';
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.grey),
                  ),
                  labelText: 'TITLE',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _description,
              child: TextFormField(
                maxLength: 500,
                maxLines: 20,
                controller: _notification_description,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Required!';
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.grey),
                  ),
                  labelText: 'DESCRIPTION',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, _notification_title.text, _notification_description.text, platform,
        payload: 'Welcome to the Local Notification demo ');
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
    DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future<void> showBigPictureNotification() async {
    var bigPictureStyleInformation = BigPictureStyleInformation(
      DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
      largeIcon: DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
      contentTitle: 'flutter devs',
      summaryText: 'summaryText',
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics,
        payload: "big image notifications");
  }

  Future<void> showNotificationMediaStyle() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'media channel id',
      'media channel name',
      'media channel description',
      color: Colors.red,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
      styleInformation: MediaStyleInformation(),
    );
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.show(
        0, 'notification title', 'notification body', platformChannelSpecifics);
  }

}
