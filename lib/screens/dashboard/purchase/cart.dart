import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  Cart(this.ctx);

  final ctx;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  List orders = [];

  initData() async{
    getPrefs('order', dec: true).then((res){
      if(res != null){
        setState(() {
          orders = res;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Keranjang'),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[

            Container(
              padding: EdgeInsets.all(10), width: Mquery.width(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Color.fromRGBO(237, 242, 250, 1),
                border: Border.all(color: Color.fromRGBO(70, 127, 207, 1))
              ),
              child: text('Selesaikan pembelian Anda'),
            ),

            Column(
              children: List.generate(orders.length, (i){
                var data = orders[i];

                return WidSplash(
                  onTap: (){ },
                  child: Container(
                    
                  ),
                );
              })
            )



          ],
        ),
      ),
    );
  }
}