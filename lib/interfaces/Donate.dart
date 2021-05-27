import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
class Donate extends StatefulWidget {
  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  String _amount_to_send,_phonenumber,_credit_card,_expiry_date,_CVV;
  final _amount = GlobalKey<FormState>();
  TextEditingController _amount_fill = TextEditingController();
  final _phone_number = GlobalKey<FormState>();
  TextEditingController _phone_number_fill = TextEditingController();
  final _creditcard = GlobalKey<FormState>();
  TextEditingController _creditcard_fill = TextEditingController();
  final _expirydate = GlobalKey<FormState>();
  TextEditingController _expirydate_fill = TextEditingController();
  final _cvv = GlobalKey<FormState>();
  TextEditingController _cvv_fill = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    payment();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _creditcard,
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty || value == null || value.length != 16 || double.tryParse(value) == null)
                    return 'Invalid Credit Card Number!';
                  setState(() {
                    _credit_card = value;
                  });
                  return null;
                },
                controller: _creditcard_fill,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  labelText: 'CREDIT CARD NUMBER',
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
              key: _expirydate,
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty || value == null || value.length != 4 || double.tryParse(value) == null)
                    return 'Invalid Expiry Date!';
                  setState(() {
                    _expiry_date = value;
                  });
                  return null;
                },
                controller: _expirydate_fill,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'MMYY',
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  labelText: 'EXPIRY DATE',
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
              key: _cvv,
              child: TextFormField(
                validator: (value){
                  if(value.isEmpty || value == null || value.length != 3 || double.tryParse(value) == null)
                    return 'Invalid CVV!';
                  setState(() {
                    _CVV = value;
                  });
                  return null;
                },
                controller: _cvv_fill,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  labelText: 'CVV',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _phone_number,
              child: TextFormField(
              validator: (value){
                if(value.isEmpty || value == null || value.length != 11 || double.tryParse(value) == null)
                  return 'Invalid Phone Number!';
                setState(() {
                  _phonenumber = value;
                });
                return null;
                },
                controller: _phone_number_fill,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '+92XXXXXXXXXX',
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  labelText: 'PHONE NUMBER',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _amount,
              child: TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty)
                    return 'Enter an amount';
                  setState(() {
                    _amount_to_send = (int.parse(value)*100).toString();
                    print(_amount_to_send);
                  });
                  return null;
                },
                controller: _amount_fill,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  labelText: 'AMOUNT',
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('Pressed');
              if(_amount.currentState.validate() /*&& _phone_number.currentState.validate() */&&
              _creditcard.currentState.validate() && _expirydate.currentState.validate() && _cvv.currentState.validate())
                payment();
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
        ],
      ),
    );
  }

  payment() async{
    var digest;
    String dateandtime = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
    String dexpiredate = DateFormat("yyyyMMddHHmmss").format(DateTime.now().add(Duration(days: 1)));
    String tre = "T"+dateandtime;
    String pp_Amount=_amount_to_send;
    String pp_BillReference="billRef";
    String pp_Description="Description";
    String pp_Language="EN";
    String pp_MerchantID="MC19255";
    String pp_Password="xv43z5csv4";
    String pp_ReturnURL="https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";
    String pp_ver = "1.1";
    String pp_TxnCurrency= "PKR";
    String pp_TxnDateTime=dateandtime.toString();
    String pp_TxnExpiryDateTime=dexpiredate.toString();
    String pp_TxnRefNo=tre.toString();
    String pp_TxnType="MWALLET";
    String ppmpf_1="03218416082";
    String IntegeritySalt = "hzx9wz9209";
    String and = '&';
    String superdata=
        IntegeritySalt+and+
            pp_Amount+and+
            pp_BillReference +and+
            pp_Description +and+
            pp_Language +and+
            pp_MerchantID +and+
            pp_Password +and+
            pp_ReturnURL +and+
            pp_TxnCurrency+and+
            pp_TxnDateTime +and+
            pp_TxnExpiryDateTime +and+
            pp_TxnRefNo+and+
            pp_TxnType+and+
            pp_ver+and+
            ppmpf_1
    ;
    var key = utf8.encode(IntegeritySalt);
    var bytes = utf8.encode(superdata);
    var hmacSha256 = new Hmac(sha256, key);
    Digest sha256Result = hmacSha256.convert(bytes);
    var url = Uri.parse('https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction');

    var response = await http.post(url, body: {
      "pp_Version": "1.1",
      "pp_InstrToken": "",
      "pp_TxnType": "MPAY",
      "pp_TxnRefNo": "T20210524203058",
      "pp_MerchantID": "MC19255",
      "pp_Password": "xv43z5csv4",
      "pp_Amount": _amount_to_send,
      "pp_TxnCurrency": "PKR",
      "pp_TxnExpiryDateTime": "20170609114800",
      "pp_BillReference": "billRef",
      "pp_Description": "Description of transaction",
      "pp_CustomerCardNumber": _credit_card,
      "pp_CustomerCardExpiry": _expiry_date,
      "pp_CustomerCardCvv": _CVV,
      "pp_SecureHash": "93F20FC143D8722F35BD0FE40B8827FB3A724717DA4E0922E9BF21FFDEF61884",
      "pp_Frequency": "SINGLE",
      "pp_TxnDateTime": dateandtime
    });

    print("response=>");
    print(response.body);
  }

  /*payment() async{
    var digest;
    String dateandtime = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
    String dexpiredate = DateFormat("yyyyMMddHHmmss").format(DateTime.now().add(Duration(days: 1)));
    String tre = "T"+dateandtime;
    String pp_Amount=_amount_to_send;
    String pp_BillReference="billRef";
    String pp_Description="Description";
    String pp_Language="EN";
    String pp_MerchantID="MC19255";
    String pp_Password="xv43z5csv4";
    String pp_ReturnURL="https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";
    String pp_ver = "1.1";
    String pp_TxnCurrency= "PKR";
    String pp_TxnDateTime=dateandtime.toString();
    String pp_TxnExpiryDateTime=dexpiredate.toString();
    String pp_TxnRefNo=tre.toString();
    String pp_TxnType="MWALLET";
    String ppmpf_1=_phonenumber;
    String IntegeritySalt = "hzx9wz9209";
    String and = '&';
    String superdata=
        IntegeritySalt+and+
            pp_Amount+and+
            pp_BillReference +and+
            pp_Description +and+
            pp_Language +and+
            pp_MerchantID +and+
            pp_Password +and+
            pp_ReturnURL +and+
            pp_TxnCurrency+and+
            pp_TxnDateTime +and+
            pp_TxnExpiryDateTime +and+
            pp_TxnRefNo+and+
            pp_TxnType+and+
            pp_ver+and+
            ppmpf_1
    ;
    var key = utf8.encode(IntegeritySalt);
    var bytes = utf8.encode(superdata);
    var hmacSha256 = new Hmac(sha256, key);
    Digest sha256Result = hmacSha256.convert(bytes);
    var url = Uri.parse('https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction');

    var response = await http.post(url, body: {
      "pp_Version": pp_ver,
      "pp_TxnType": pp_TxnType,
      "pp_Language": pp_Language,
      "pp_MerchantID": pp_MerchantID,
      "pp_Password": pp_Password,
      "pp_TxnRefNo": tre,
      "pp_Amount": pp_Amount,
      "pp_TxnCurrency": pp_TxnCurrency,
      "pp_TxnDateTime": dateandtime,
      "pp_BillReference": pp_BillReference,
      "pp_Description": pp_Description,
      "pp_TxnExpiryDateTime":dexpiredate,
      "pp_ReturnURL": pp_ReturnURL,
      "pp_SecureHash": sha256Result.toString(),
      "ppmpf_1":ppmpf_1
    });

    print("response=>");
    print(response.body);
  }*/

}
