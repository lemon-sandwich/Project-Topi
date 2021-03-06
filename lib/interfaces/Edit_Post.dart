import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/interfaces/Loading_Screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Edit_Post extends StatefulWidget {
  bool empty;
  String title,amount,description,donation_type;
  Edit_Post(this.empty,this.title,this.amount,this.description,this.donation_type, {Key, key}) : super(key: key);
  @override
  _Edit_PostState createState() => _Edit_PostState();
}

class _Edit_PostState extends State<Edit_Post> {
  TextEditingController _post_title = TextEditingController();
  TextEditingController _post_description = TextEditingController();
  TextEditingController _post_amount = TextEditingController();
  TextEditingController _post_other_donation = TextEditingController();
  String _donation_selected;
  bool _other = false;
  final _title = GlobalKey<FormState>();
  final _description = GlobalKey<FormState>();
  final _other_donation = GlobalKey<FormState>();
  final _amount = GlobalKey<FormState>();
  DatabaseReference _databaseReference;
  final _donation_ref = FirebaseDatabase.instance.reference();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _show = false;
  List<String> _donation_types = ['Zakat','Fitrana','Sadqa','Other'];
  int counter;
  String result;
  void readData() {
    counter = 1;
    _donation_ref.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value['Donations'];
      if(values == null){
        print('No Other Types of Donations Added.');
      }
      else {
        print('Values: ' + values.toString());
        print('Key: ' + values.keys.toString());
        result = values.keys.toString().substring(
            values.keys.toString().indexOf('(') + 1,
            values.keys.toString().indexOf(')'));
        print('Result: ' + result);
        for (var key in values.values) {
          print(key);
          _donation_types = key['Donation Types'].cast<String>();
          break;
        }
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      print('Loading...');
      print(_donation_types);
      if (_donation_types[0] != null) {
        timer.cancel();
        print('Donations NOT NULL');
        setState(() {
          _show = true;
        });
      }
    });
    _databaseReference = FirebaseDatabase.instance.reference().child('Posts');
    _donation_selected = 'Zakat';
    readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _show
        ? Scaffold(
      // resizeToAvoidBottomInset: false,
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          backgroundColor: Colors.blueAccent[100],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  if (_title.currentState.validate() &&
                      _amount.currentState.validate() && _description.currentState.validate()) {
                    saveInfo();
                    if (_other == true &&
                        _other_donation.currentState.validate()) {
                      Navigator.of(context).pop();
                    } else if (_other == false) Navigator.of(context).pop();
                  }
                },
                child: Text('POST',
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
                  controller: _post_title,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required!';
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
                    if (value == null || value.isEmpty) return 'Required!';
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
                  validator: (value)
                  {
                    if(value == null || value.isEmpty)
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
                dropdownColor: Colors.green[50],
                isExpanded: true,
                items: _donation_types.map((String dropDownItems) {
                  return DropdownMenuItem<String>(
                    value: dropDownItems,
                    child: Text(dropDownItems,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w300,
                        )),
                  );
                }).toList(),
                onChanged: (String newVal) {
                  setState(() {
                    _donation_selected = newVal;
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
          ],
        ))
        : Loading_Screen();
  }

  void saveInfo() async {
    String title = _post_title.text;
    String amount = _post_amount.text;
    String description = _post_description.text;
    String donation_type;
    if(_other)
    {
      int counter = 0;
      donation_type = _post_other_donation.text;
      print(_donation_types);
      print("Length: " + _donation_types.length.toString());
      counter = _donation_types.length;
      List newd = new List(counter+1);
      var i = 0;
      for(;i<counter;i++) {
        if(_donation_types[i] == 'Other')
          newd[i] = _post_other_donation.text;
        else
          newd[i] = _donation_types[i];
      }
      newd[i] = 'Other';
      var d_types = {
        'Donation Types' : newd
      };
      _donation_ref.child('Donations').remove();
      _donation_ref.child('Donations').push().set(d_types);
    }
    else
      donation_type = _donation_selected;

    Map<String, String> info = {
      'Title': title,
      'Amount': amount,
      'Donation Type': donation_type,
      'Description': description,
    };
    _databaseReference.push().set(info);
  }
}
