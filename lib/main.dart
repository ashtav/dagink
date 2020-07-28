import 'package:dagink/screens/login/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // cegah landscape orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    Color _black = Colors.black54;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dagink',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            headline6: TextStyle(
              color: _black
            )
          ),
          iconTheme: IconThemeData(
            color: _black
          )
        ),
        iconTheme: IconThemeData(
          color: _black, size: 20
        ),
        buttonTheme: ButtonThemeData(minWidth: 0),
        textTheme: TextTheme(
          bodyText2: TextStyle(fontFamily: 'Nunito', fontSize: 15)
        )
      ),
      home: Authentication(),
    );
  }
}

