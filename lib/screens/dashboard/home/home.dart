import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home(this.ctx);

  final ctx;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: text('lorem ipsum dolor'),
      ),
    );
  }
}