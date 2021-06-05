import 'package:flutter/material.dart';
import 'package:pa3/Pages/login.dart';
import 'package:pa3/Pages/NavigationPage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => MyHomePage(title: '2015311771 KangGyeongUn'),
        '/login' : (context) => login(),
      },
      initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String login_msg = "Login Please...";
  final loginIdController = TextEditingController();
  final loginPWController = TextEditingController();
  final String logId = 'skku';
  final String logPW = '1234';


  void check(){
    if(loginIdController.text.toString() == logId &&
        loginPWController.text.toString() == logPW) {
        Navigator.pushReplacement(context, new MaterialPageRoute(
            builder: (context) => new login(logID :logId))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
              '$login_msg',
              style: TextStyle(
                fontSize:24,
                color: Colors.grey,
              )
            ),
            Text("\n\n"),
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ID: ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),

                      SizedBox(
                        width: 200,
                        child:
                        TextField(
                          controller: loginIdController,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PW: ',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child:
                        TextField(
                          controller: loginPWController,
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                      onPressed: check,
                      color: Colors.blue,
                      child: Text('Login',
                      style: TextStyle(
                        color: Colors.white,
                      ),)
                  ),
                ],

              ),

            )
          ],
        ),
      ),
    );
  }
}
