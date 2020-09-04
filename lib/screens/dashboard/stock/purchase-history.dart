import 'package:dagink/screens/dashboard/stock/detail-purchase.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class PurchaseHistory extends StatefulWidget {
  PurchaseHistory(this.ctx);

  final ctx;

  @override
  _PurchaseOrderState createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseHistory> {

  bool loading = false;

  List orders = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Http.get('purchase?created_by='+uid, then: (_, data){
      Map res = decode(data);
      var _data = res['data'];

      // filter data (order or history) berdasarkan tanggal
      List filtered = [];

      final now = DateTime.now();

      for (var i = 0; i < _data.length; i++) {
        var date = DateTime.parse(_data[i]['created_at']);

        if(now.difference(date).inHours > 24 || _data[i]['status'] != 'waiting'){
          filtered.add(_data[i]);
        }
      }

      orders = filter = filtered;

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
        padding: EdgeInsets.only(bottom: 70),
        itemCount: filter.length,
        itemBuilder: (BuildContext context, i){
          var data = filter[i];

          return WidSplash(
              onTap: (){
                Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => DetailPurchase(widget.ctx, data: data)));
              },
              onLongPress: data['status'] != 'waiting' ? null : (){
                Wh.confirmation(widget.ctx, message: 'Yakin ingin membatalkan pembelian ini?', confirmText: 'Batalkan Pembelian', then: (res){
                  if(res == 0){
                    Navigator.pop(widget.ctx);

                    showDialog(
                      context: widget.ctx,
                      child: OnProgress()
                    );

                    Http.put('purchase/'+data['id'].toString()+'/cancel', data: {}, then: (_, data){
                      Navigator.pop(widget.ctx);
                      Wh.toast('Pembelian dibatalkan');

                      setState(() {
                        orders[i]['status'] = 'cancel';
                        filter = orders;
                      });

                    }, error: (err){
                      onError(context, response: err);
                    });
                  }
                });
              },
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
                          color: data['status'] == 'waiting' ? TColor.orange() : data['status'] == 'confirmed' ? TColor.blue() : data['status'] == 'approved' ? TColor.green() : data['status'] == 'cancel' ? TColor.gray() : TColor.red(),
                          borderRadius: BorderRadius.circular(2)
                        ),
                        child: text(data['status'], color: Colors.white),
                      )
                    ]
                  ),

                ],
              )
          );
        },
      ),
    );
  }
}