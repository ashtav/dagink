import 'dart:async';

import 'package:dagink/screens/dashboard/stock/cart.dart';
import 'package:dagink/screens/dashboard/stock/forms/form-purchase.dart';
import 'package:dagink/screens/dashboard/stock/purchase-history.dart';
import 'package:dagink/screens/dashboard/stock/purchase-order.dart';
import 'package:dagink/screens/dashboard/stock/stock.dart';
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

  bool loading = false, isCartEmpty = true;
  List purchases = [], filter = [];

  int tab = 0;

  var keyword = TextEditingController();

  getData() async{
    // get cart data
    getPrefs('order', dec: true).then((res){ print(res);
      setState(() {
        isCartEmpty = res == null;
      });
    });
  }

  Widget tabContent = SizedBox.shrink();

  @override
  void initState() {
    getData();

    super.initState(); tabContent = tab == 0 ? PurchaseOrder(widget.ctx) : PurchaseHistory(widget.ctx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Pembelian', elevation: 0, center: true, actions: [
        IconButton(
          icon: loading ? Wh.spiner() : Icon(Ln.wallet()),
          onPressed: loading ? null : (){
            Wh.dialog(context, child: InfoSaldo());
          },
        ),

        IconButton(
          icon: Stack(
            children: [
              Icon(Ln.cart()),

              Positioned(
                child: isCartEmpty ? SizedBox.shrink() : ZoomIn(
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.red
                    ),
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
                      tabContent = PurchaseOrder(widget.ctx);
                    });
                  });
                }
              }
            }).then((value){
              getData();
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

                        tabContent = tab == 0 ? PurchaseOrder(widget.ctx) : PurchaseHistory(widget.ctx);
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
        child: Icon(Ln.plus()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormPurchase(widget.ctx))).then((value){
            if(value != null){
              if(value['added'] != null){
                tabContent = SizedBox.shrink();

                Timer(Duration(milliseconds: 300), (){
                  setState(() {
                    tabContent = PurchaseOrder(widget.ctx);
                  });
                });
              }
            }
          }).then((value) => getData());
        },
      ),
    );
  }
}

class InfoSaldo extends StatefulWidget {
  @override
  _InfoSaldoState createState() => _InfoSaldoState();
}

class _InfoSaldoState extends State<InfoSaldo> {

  Map user = {};

  initAuth() async{
    var auth = await Auth.user();
    setState(() {
      user = auth;
    });
  }

  @override
  void initState() {
    initAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: TColor.azure(), width: 2),
                  borderRadius: BorderRadius.circular(2)
                ),
                margin: EdgeInsets.only(right: 13),
                padding: EdgeInsets.all(7),
                child: Icon(Ln.wallet(), size: 25, color: TColor.azure())
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text('Informasi Saldo'),
                  text('Rp '+Cur.rupiah(user['balance']), size: 20, bold: true, color: TColor.azure()),
                ],
              )

            ],
          )
        ],
      ),
    );
  }
}