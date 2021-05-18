import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Loading_Screen.dart';
import 'package:page_transition/page_transition.dart';

class Post_Info extends StatefulWidget {
  Map _post;
  Post_Info(this._post, {Key, key}) : super(key: key);
  @override
  _Post_InfoState createState() => _Post_InfoState();
}

class _Post_InfoState extends State<Post_Info> {
  TextEditingController _post_title;
  TextEditingController _post_description;
  TextEditingController _post_amount;
  TextEditingController _post_other_donation;
  String _donation_selected;
  bool _other = false;
  final _title = GlobalKey<FormState>();
  final _description = GlobalKey<FormState>();
  final _other_donation = GlobalKey<FormState>();
  final _amount = GlobalKey<FormState>();
  List<String> _donation_types = ['Zakat', 'Fitrana', 'Sadqa', 'Other'];
  final _donation_ref = FirebaseDatabase.instance.reference();
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  FirebaseAuth _auth = FirebaseAuth.instance;
  int counter;
  String result;
  bool _show = false;
  void readData() {
    setState(() {
      _show = false;
    });
    counter = 1;
    _donation_ref.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value['Donations'];
      if (values == null) {
        print('No Other Types of Donations Added.');
      } else {
        print('Values: ' + values.toString());
        print('Key: ' + values.keys.toString());
        result = values.keys.toString().substring(
            values.keys.toString().indexOf('(') + 1,
            values.keys.toString().indexOf(')'));
        print('Result: ' + result);
        for (var key in values.values) {
          print(key);
          _donation_types = key['Donation Types'].cast<String>();
          setState(() {
            _show = true;
          });
          break;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _post_title = TextEditingController(text: widget._post['Title']);
    _post_amount = TextEditingController(text: widget._post['Amount']);
    _post_description =
        TextEditingController(text: widget._post['Description']);
    _donation_selected = widget._post['Donation Type'];
    readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget._post['Title'],
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  letterSpacing: 2,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '|',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w200),
                ),
                TextButton(
                  onPressed: () {
                    if (_title.currentState.validate() &&
                        _amount.currentState.validate() &&
                        _description.currentState.validate()) {
                      saveEditedInfo();
                      if (_other == true &&
                          _other_donation.currentState.validate()) {
                        Navigator.of(context).pop();
                      } else if (_other == false) Navigator.of(context).pop();
                    }
                  },
                  child: Text('DONE',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      )),
                )
              ],
            ),
          ],
        ),
      ),
      body: _show
          ? Scaffold(
              backgroundColor: Colors.grey[100],
              // resizeToAvoidBottomInset: false,

              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _title,
                      child: TextFormField(
                        maxLength: 50,
                        maxLines: 2,
                        controller: _post_title,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Required!';
                          return null;
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
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
                      key: _amount,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _post_amount,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Required!';
                          return null;
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          labelText: 'AMOUNT REQUIRED',
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
                        maxLength: 200,
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Required!';
                          return null;
                        },
                        controller: _post_description,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      //dropdownColor: Colors.green[50],
                      isExpanded: true,
                      items: _donation_types.map((String dropDownItems) {
                        return DropdownMenuItem<String>(
                          value: dropDownItems,
                          child: Text(dropDownItems,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w300,
                              )),
                        );
                      }).toList(),
                      onChanged: (String newVal) {
                        setState(() {
                          _donation_selected = newVal;
                          print(newVal);
                          if (newVal == 'Other')
                            _other = true;
                          else
                            _other = false;
                        });
                      },
                      value: _donation_selected,
                    ),
                  ),
                  _other
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _other_donation,
                            child: TextFormField(
                              controller: _post_other_donation,
                              validator: (value) {
                                _donation_selected = value;
                                if (value == null || value.isEmpty)
                                  return 'Required';
                                return null;
                              },
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                labelText: 'DONATION TYPE',
                                labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            onPressed: () {
                              int _total_posts = 0;
                              databaseReference
                                  .child('Posts')
                                  .child('Total Posts')
                                  .once()
                                  .then((DataSnapshot snapshot) {
                                setState(() {
                                  _total_posts = snapshot.value['Total Posts'];
                                });
                              }).then((_) {
                                print('Total Posts: '  + _total_posts.toString());
                                databaseReference.child('Posts').child('Total Posts').update({
                                  'Total Posts': --_total_posts,
                                });
                              });
                              databaseReference
                                  .child('Posts')
                                  .child(widget._post['Hash'])
                                  .remove();

                              Navigator.of(context).pop();
                            },
                            child: Text('DELETE'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            )),
                      )
                    ],
                  )
                ],
              ))
          : Loading_Screen(),
    );
  }

  void saveEditedInfo() {
    databaseReference.child('Posts').child(widget._post['Hash']).update(
      {
        'Title': _post_title.text,
        'Amount': _post_amount.text,
        'Description': _post_description.text,
        'Donation Type': _donation_selected,
      },
    );
  }
}
