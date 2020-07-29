import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class PurchaseOrder extends StatefulWidget {
  @override
  _PurchaseOrderState createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {

  bool loading = false;

  List orders = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Http.get('purchase?created_by='+uid, then: (_, data){
      Map res = decode(data);
      orders = filter = res['data'];

      if(mounted) setState(() => loading = false );
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
    return loading ? ListSkeleton(length: 15) : filter.length == 0 ? 

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
    
    RefreshIndicator(
      onRefresh: () async{
        getData();
      },
      child: ListView.builder(
        itemCount: filter.length,
        itemBuilder: (BuildContext context, i){
          var data = filter[i];

          return WidSplash(
            onTap: (){

            },
            child: WidSplash(
              onTap: (){ },
              padding: EdgeInsets.all(15), color: i % 2 == 0 ? TColor.silver() : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(data['code'], bold: true),
                      text(dateFormat(data['transaction_date']))
                    ]
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      text(nformat(data['grand_total']), bold: true),
                      Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          color: TColor.orange(),
                          borderRadius: BorderRadius.circular(2)
                        ),
                        child: text(data['status'], color: Colors.white),
                      )
                    ]
                  ),

                ],
              )
              
            ),
          );
        },
      ),
    );
  }
}