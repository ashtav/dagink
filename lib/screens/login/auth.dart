import 'dart:async';

import 'package:dagink/screens/dashboard/dashboard.dart';
import 'package:dagink/screens/login/login.dart';
import 'package:dagink/services/api/api.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {

  Timer timer;

  _toLogin(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  initAuthentication() async{

    timer = Timer(Duration(seconds: 10), (){
      _toLogin();
    });

    var token = await Auth.token();
    if(token != null){
      Request.get('me', then: (_, data){
        timer.cancel();
        Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
      }, error: (err){ _toLogin(); });
    }else{
      timer.cancel();
      _toLogin();
    }
  }

  @override
  void initState() {
    super.initState(); initAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    statusBar(color: Colors.transparent, darkText: true);

    return Scaffold(
      backgroundColor: TColor.silver(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wh.spiner(size: 50, margin: 25),
            text('Authorisasi, mohon menunggu')
          ]
        )
      )
    );
  }
}