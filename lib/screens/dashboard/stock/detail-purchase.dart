import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class DetailPurchase extends StatefulWidget {
  DetailPurchase(this.ctx, {this.data});

  final ctx, data;

  @override
  _DetailPurchaseState createState() => _DetailPurchaseState();
}

class _DetailPurchaseState extends State<DetailPurchase> {

  List items = [];

  bool loading = true;
  int grandTotal = 0, qty = 0, pcs = 0, viewPrice = 0;

  getData(){
    Http.get('purchase/'+widget.data['id'].toString(), then: (_, data){
      setState((){
        loading = false;
        items = decode(data)['data']['details'];

        grandTotal = 0; qty = 0; pcs = 0;

        for (var i = 0; i < items.length; i++) {
          grandTotal += items[i]['price'];

          qty += items[i]['qty_approve'];
          pcs += items[i]['qty_pcs_approve'];
        }
      });
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }


  @override
  void initState() {
    super.initState(); getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: widget.data['code']),

      body: loading ? ListSkeleton(length: 15) : items.length == 0 ?

        RefreshIndicator( onRefresh: () async{  getData();  },
          child: Center(
            child: PreventScrollGlow(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Wh.noData(message: 'Anda tidak memiliki transaksi dalam proses\nTap + untuk menambahkan')
                ],
              ),
            ),
          )
        ) :

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, i){
                  var data = items[i]; print(data);

                  return WidSplash(
                    onTap: (){
                      setState(() {
                        viewPrice = data['id'] == viewPrice ? 0 : data['id'];
                      });
                    },
                    color: i % 2 == 0 ? TColor.silver() : Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[

                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(data['product_code'], bold: true),
                                text(data['product_name']),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              text(viewPrice == data['id'] ? '@'+nformat(data['price']) : nformat(data['subtotal_approve'])),
                              text(data['qty_approve'].toString()+' / '+data['qty_pcs_approve'].toString())
                            ]
                          )


                        ],
                      )
                      
                    ),
                  );
                }
              )
            ),

            Container(
              width: Mquery.width(context),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12))
              ),
              padding: EdgeInsets.all(15),
              child: text('Grand Total : '+nformat(grandTotal.toString())+' ('+qty.toString()+'/'+pcs.toString()+')', bold: true),
            )

          ]
        )
    
    );
  }
}