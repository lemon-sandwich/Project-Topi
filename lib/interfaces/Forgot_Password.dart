import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/interfaces/Home_page.dart';
import 'package:page_transition/page_transition.dart';


class Forgot_Password extends StatefulWidget {
  @override
  _Forgot_PasswordState createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {

  String phoneNumber;
  String verificationID;
  String smscode = '2464';

  Future<void> VerifyPhone() async{
    final PhoneVerificationCompleted veriSuccess = (user){
      print("verified!");
    };
    final PhoneVerificationFailed veriFailed = (FirebaseAuthException exception){
      print("${exception.message}");
    };
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verID)
    {
      this.verificationID = verID;
    };
    final PhoneCodeSent smsCodeSent =  (String verID,[int forceCodeResend]){
      this.verificationID = verID;
      smsCodeDialog(context).then((value){
        print("Verified!");
      });
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        verificationCompleted: veriSuccess,
        verificationFailed: veriFailed,
        codeSent: smsCodeSent,
        timeout: Duration(seconds: 5),
        codeAutoRetrievalTimeout: autoRetrieve);
  }
  Future<bool> smsCodeDialog(BuildContext context){
    return showDialog(context: context,
      barrierDismissible: false,
      builder: (context){
        return new AlertDialog(
        title: Text('SMS CODE'),
        content: TextField(
          onChanged: (value)
          {
            this.smscode = value;

            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        contentPadding: EdgeInsets.all(10),
        actions: <Widget>[
          new FlatButton(onPressed: ()
              {
              }, child: Text('Done'))
        ],
      );
      },
    );
  }
  final _phoneNumberFill = GlobalKey<FormState>();
  TextEditingController _phoneNumber;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[50],
        resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
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
                        this.phoneNumber = '+92' + value;
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
            SizedBox(height: 20,),
            Container(
              height: 40,
              child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7,
                  child: InkWell(
                    onTap: () {
                      if(_phoneNumberFill.currentState.validate())
                        VerifyPhone();
                      },
                      child: Center(
                      child: Text(
                      'VERIFY',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat-Thin.tff',
                              fontSize: 20,
                            ))),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
