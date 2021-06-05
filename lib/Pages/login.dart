import 'package:flutter/material.dart';
import 'package:pa3/Pages/NavigationPage.dart';

class login extends StatelessWidget {
  String logID;

  login({Key key, this.logID}) : super(key: key);

  final String title = '2015311771 KangGyeongUn';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '2015311771 KangGyeongUn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => loginPage(title: '2015311771 KangGyeongUn', id: logID,),
        '/navi' : (context) => NavigationPage(logid: logID),
      },
      initialRoute: '/',
    );
    throw UnimplementedError();
  }
}

class loginPage extends StatelessWidget {
  final String title;
  final String id;
  String cur_page = 'Login Page';

  loginPage({Key key, this.title, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'CORONA LIVE',
              style: TextStyle(
                fontSize: 36,
                color: Colors.blueGrey,
              ),
            ),
            Text(
                'Login Success. Hello $id!!',
                style: TextStyle(
                  fontSize:24,
                  color: Colors.lightBlue,
                )
            ),
            Text("\n\n\n"),
            Image.asset('images/map.jpg'),
            Text("\n\n"),
            RaisedButton(
                onPressed:(){
                  Navigator.pushReplacement(context, new MaterialPageRoute(
                      builder: (context) => new NavigationPage(logid: id, previousPage: cur_page,))
                  );
                },
                color: Colors.blue,
                child: Text('Start CORONA LIVE',
                  style: TextStyle(
                    color: Colors.white,
                  ),)
            ),
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }

}