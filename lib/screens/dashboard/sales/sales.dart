import 'package:dagink/screens/dashboard/sales/forms/form-sale.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.azure(),
        heroTag: 'sale',
        child: Icon(Ln.plus()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormSale(widget.ctx))).then((value){
            // if(value != null){
            //   if(value['added'] != null){
            //     tabContent = SizedBox.shrink();

            //     Timer(Duration(milliseconds: 300), (){
            //       setState(() {
            //         tabContent = PurchaseOrder(widget.ctx);
            //       });
            //     });
            //   }
            // }
          });
        },
      ),
    );
  }
}