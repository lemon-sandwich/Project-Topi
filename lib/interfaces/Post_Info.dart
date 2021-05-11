import 'package:flutter/material.dart';

class Post_Info extends StatefulWidget {
  Map _post;
  Post_Info(this._post, {Key,key}) : super(key:key);
  @override
  _Post_InfoState createState() => _Post_InfoState();
}

class _Post_InfoState extends State<Post_Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Title: ' + widget._post['Title'],
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
