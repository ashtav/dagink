import 'dart:async';

import 'package:dagink/screens/dashboard/purchase/cart.dart';
import 'package:dagink/screens/dashboard/purchase/forms/form-purchase.dart';
import 'package:dagink/screens/dashboard/purchase/purchase-history.dart';
import 'package:dagink/screens/dashboard/purchase/purchase-order.dart';
import 'package:dagink/screens/dashboard/purchase/stock.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Purchase extends StatefulWidget {
  Purchase(this.ctx);

  final ctx;

  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {

  bool loading = false;
  List purchases = [], filter = [];

  int tab = 0;

  var keyword = TextEditingController();

  getData() async{
    setState(() {
      loading = true;
      keyword.clear();
    });

    String uid = await Auth.id();

    Http.get('purchase?created_by='+uid, then: (_, data){
      Map res = decode(data);
      purchases = filter = res['data'];

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }

  Widget tabContent = PurchaseOrder();

  @override
  void initState() {
    super.initState(); tabContent = tab == 0 ? PurchaseOrder() : PurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Pembelian', elevation: 0, back: false, center: true, actions: [
        IconButton(
          icon: loading ? Wh.spiner() : Icon(Ln.sortNumeric()),
          onPressed: loading ? null : (){
            Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Stock(widget.ctx)));
          },
        ),

        IconButton(
          icon: Stack(
            children: [
              Icon(Ln.cart()),

              Positioned(
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.red
                  ),
                ),
              )

            ]
          ),
          
          onPressed: (){
            Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Cart(widget.ctx))).then((value){
              if(value != null){
                if(value['added'] != null){
                  tabContent = SizedBox.shrink();

                  Timer(Duration(milliseconds: 300), (){
                    setState(() {
                      tabContent = PurchaseOrder();
                    });
                  });
                }
              }
            });
          },
        ),

      ]),

      body: //loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Tidak ada data pembelian\nTap + untuk menambahkan') :

        Column(
          children: [
            
            Container(
              color: Colors.white,
              child: Row(
                children: List.generate(2, (i){
                  List labels = ['Order','Riwayat'];

                  return WidSplash(
                    onTap: (){
                      setState(() {
                        tab = i;

                        tabContent = tab == 0 ? PurchaseOrder() : PurchaseHistory();
                      });
                    },
                    child: AnimatedContainer(
                      curve: Curves.easeOut,
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: i == tab ? Color.fromRGBO(234, 244, 255, 1) : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: i == tab ? TColor.azure() : Colors.transparent, width: 1.5
                          )
                        )
                      ),
                      padding: EdgeInsets.all(10), width: Mquery.width(context) / 2,
                      child: text(labels[i], align: TextAlign.center),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: tabContent
            )
          ]
        ),
      
       
      floatingActionButton: FloatingActionButton(
        heroTag: 'purchase',
        child: Icon(Ln.bag()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormPurchase(widget.ctx))).then((value){
            if(value != null){
              if(value['added'] != null){
                tabContent = SizedBox.shrink();

                Timer(Duration(milliseconds: 300), (){
                  setState(() {
                    tabContent = PurchaseOrder();
                  });
                });
              }
            }
          });
        },
      ),
    );
  }
}