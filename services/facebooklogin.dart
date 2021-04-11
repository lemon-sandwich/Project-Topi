import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Account_Info.dart';
import 'package:flutter_app/interfaces/Home_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginWithFacebook extends StatefulWidget {
  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {

  bool _isLogin = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FacebookLogin _facebookLogin = FacebookLogin();
  User _user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#3b5998"),
      body: Center(
        child: Container(
          height: 40,
          color: Colors.transparent,
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  //style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(20),
                color: HexColor("#3b5998"),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      onTap: () async{
                        await _handleLogin();
                      },
                      child: Row(
                        children: [
                          Image.asset('Images/facebook.png',color: Colors.white,),
                          SizedBox(width: 10),
                          Text(
                            'Login with Facebook',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Montserrat-Thin.ttf'),
                          )],)
                  ),
                ],
              )),
        ),
      ) /*Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             CircleAvatar(
               radius: 80,
               backgroundImage: NetworkImage(_user.photoURL),
             ),
            Text(_user.displayName),
            SizedBox(height: 30),
            OutlineButton(onPressed: () async {
              await _signOut();
            })
          ],
        )
      ),*/
    );
  }
  Future _handleLogin() async {
    FacebookLoginResult _result =  await _facebookLogin.logIn(['email']);
    switch(_result.status)
    {
      case FacebookLoginStatus.cancelledByUser:
        print('Cancelled By User');
        break;
      case FacebookLoginStatus.error:
        print('Error');
        break;
      case FacebookLoginStatus.loggedIn:
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                duration: Duration(milliseconds: 500),
                child: Home_page()));
        await _loginWithFacebook(_result);
        break;
    }
  }
  Future _loginWithFacebook(FacebookLoginResult _result) async{
    FacebookAccessToken _accessToken = _result.accessToken;
    AuthCredential _credential = FacebookAuthProvider.credential(_accessToken.token);
    var a = await _auth.signInWithCredential(_credential);
    setState(() {
      _isLogin = true;
      _user = a.user;
    });
  }

 /* Future _signOut() async {
    await _auth.signOut().then((value) {
      _facebookLogin.logOut();
      _isLogin = false;

    });
  }*/
}


