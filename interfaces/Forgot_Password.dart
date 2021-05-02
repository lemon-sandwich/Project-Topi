import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/interfaces/Home_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sms_autofill/sms_autofill.dart';


class Forgot_Password extends StatefulWidget {
  @override
  _Forgot_PasswordState createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {

  TextEditingController _email;
  String email;
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                  flex: 1,
                  child: SizedBox(width: 10,)),
              Flexible(
                flex: 20,
                child: TextFormField(
                  controller: _email,
                  onChanged: (value){
                    email = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'EMAIL',
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Montserrat-Thin.ttf',
                    ),
                  ),

                ),
              ),
              Flexible(
                  flex: 1,
                  child: SizedBox(width: 10,))
            ],
          ),
          SizedBox(height: 30,),
          Container(
              height: 40,
              child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7,
                  child: InkWell(
                    onTap: (){
                      auth.sendPasswordResetEmail(email: email).then((_){
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      });
                    },

                    child: Center(
                        child: Text('SEND REQUEST',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat-Thin.tff',
                              fontSize: 20,
                            ))),
                  )))
        ],
      ),
    );
  }
}
