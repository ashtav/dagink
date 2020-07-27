import 'package:dagink/services/api/api.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {

  bool loading = false;

  List orders = [], filter = [];

  @override
  Widget build(BuildContext context) {
    return loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Anda tidak memiliki riwayat transaksi\nTap + untuk menambahkan') : 
    
    ListView.builder(
      itemCount: filter.length,
      itemBuilder: (BuildContext context, i){
        return WidSplash(
          onTap: (){

          },
          child: Container(
            child: text('lorem')
          ),
        );
      },
    );
  }
}