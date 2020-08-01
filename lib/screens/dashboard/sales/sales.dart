import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';

class Sales extends StatefulWidget {
  Sales(this.ctx);

  final ctx;

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Penjualan', back: false, center: true),
    );
  }
}