import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pa3/Pages/casePage.dart';
import 'package:pa3/Pages/vaccinePage.dart';

class NavigationPage extends StatelessWidget {
  final String title = 'Menu';
  String logid;
  final String previousPage;

  NavigationPage({Key key, this.logid, this.previousPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => naviPage(title: title, logid: logid, previousPage: previousPage),
        '/casePage' : (context) => casePage(logid: logid),
        '/vaccinePage' : (context) => vaccine(logid: logid),
      },
      initialRoute: '/',
    );
    throw UnimplementedError();
  }

}

class naviPage extends StatelessWidget {
  final String title;
  final String previousPage;
  String logid;

  naviPage({Key key, this.title, this.logid, this.previousPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed : (){Navigator.pushReplacement(context, new MaterialPageRoute(
                      builder: (context) => new cases(logid: logid))
                  );},
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.coronavirus_outlined),
                      Text('        Cases/Deaths')
                    ],
                  ),
                ),
                FlatButton(
                  onPressed : (){Navigator.pushReplacement(context, new MaterialPageRoute(
                      builder: (context) => new vaccine(logid: logid))
                  );},
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.local_hospital),
                      Text('        Vaccine')
                    ],
                  ),
                ),
                Text('\n\n\n\n\n\n\n\n\n\n'),
                Text('Welcome! $logid'),
                Text('Previous: $previousPage',style: TextStyle(
                  fontSize: 20,
                  color: Colors.indigo,
                ),),
              ]

          )
      ),
    );
    throw UnimplementedError();
  }
}
