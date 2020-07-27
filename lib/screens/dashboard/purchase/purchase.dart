import 'package:dagink/screens/dashboard/purchase/forms/form-purchase.dart';
import 'package:dagink/screens/dashboard/purchase/purchase-history.dart';
import 'package:dagink/screens/dashboard/purchase/purchase-order.dart';
import 'package:dagink/services/api/api.dart';
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

    Request.get('purchase?created_by='+uid, then: (_, data){
      Map res = decode(data);
      purchases = filter = res['data'];

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Pembelian', elevation: 0, actions: [
        IconButton(
          icon: loading ? Wh.spiner() : Icon(Ln.refresh()),
          onPressed: loading ? null : (){
            getData();
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
              child: tab == 0 ? PurchaseOrder() : PurchaseHistory()
            )
          ]
        ),
      
       
      floatingActionButton: FloatingActionButton(
        heroTag: 'purchase',
        child: Icon(Ln.bag()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormPurchase(widget.ctx))).then((value){
            if(value != null){
              getData();
            }
          });
        },
      ),
    );
  }
}