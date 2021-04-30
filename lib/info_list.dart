import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoList extends StatefulWidget {
  @override
  _InfoListState createState() => _InfoListState();
}

class _InfoListState extends State<InfoList> {
  @override
  Widget build(BuildContext context) {

    final info = Provider.of<QuerySnapshot>(context);

    print("INFO: ");
    print(info.docs);
    //for(var doc in info.docs)
      //{
        //print(doc.data());
      //}

    return Text('asd');
  }
}
