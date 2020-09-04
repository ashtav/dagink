import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class DetailCart extends StatefulWidget {
  DetailCart(this.ctx, {this.data});

  final ctx, data;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<DetailCart> {

  bool loading = false, isSubmit = false;

  List orders = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    Http.get('purchase/'+widget.data['id'].toString(), then: (_, data){
      var res = decode(data)['data'];
      orders = filter = res['details']; print(res);

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }

  submit(){

  }

  @override
  void initState() {
    super.initState(); getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: widget.data['code'], center: true),

      body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Anda tidak memiliki barang yang disimpan\nTap + untuk menambahkan') : 
      
      Column(
        children: [

          Expanded(
            child: RefreshIndicator(
            onRefresh: () async{
              getData();
            },
            child: ListView.builder(
              itemCount: filter.length,
              itemBuilder: (BuildContext context, i){
                var data = filter[i];

                return WidSplash(
                    onTap: (){ },
                    padding: EdgeInsets.all(15), color: i % 2 == 0 ? TColor.silver() : Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text(data['product']['name'], bold: true),
                              // text(dateFormat(data['transaction_date']))
                            ]
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              text(data['qty'].toString()+' / '+data['qty_pcs'].toString()),
                            ]
                          ),
                        ),

                      ],
                    )
                    
                );
              },
            ),
          )
          ),

          Container(
            padding: EdgeInsets.all(15),
            child: Button(
              onTap: isSubmit ? null : (){ submit(); },
              text: 'Order Sekarang', isSubmit: isSubmit,
            ),
          )
        ]
      )
    );
  }
}