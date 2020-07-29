import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class SavePurchase extends StatefulWidget {
  SavePurchase(this.ctx, {this.data});

  final ctx, data;

  @override
  _SavePurchaseState createState() => _SavePurchaseState();
}

class _SavePurchaseState extends State<SavePurchase> {

  bool isSubmit = false, isSave = false;
  double total = 0.0;

  submit(){
    setState(() {
      isSubmit = true;
    });

    List formData = [];

    for (var i = 0; i < widget.data.length; i++) {
      var data = widget.data[i];

      formData.add({
        'product_id': data['product_id'].toString(),
        'qty': data['qty'].toString(),
        'qty_pcs': data['qty_pcs'].toString()
      });
    }

    var _data = {'items': formData};

    Http.post('purchase', data: encode(_data), debug: true, header: {'Content-Type': 'application/json'}, then: (_, data){
      setState(() => isSubmit = false );
      Navigator.pop(context, {'added': true});
    }, error: (err){
      setState(() => isSubmit = false );
      onError(context, response: err);
    });
  }

  save() async{
    var data = widget.data; // data baru

    getPrefs('order', dec: true).then((res){
      if(res != null){

        var order = res; // data lama

        for (var item in data) {
          // tambahkan data baru ke data lama
          int io = order.indexWhere((i) => i['product_id'] == item['product_id']); // periksa item

          if(io > -1){ // jika ada, update
            var qty = order[io]['qty'], pcs = order[io]['qty_pcs'];

            qty += item['qty'];
            pcs += item['qty_pcs'];

            order[io]['qty'] = qty;
            order[io]['qty_pcs'] = pcs;
          }else{
            order.add(item);
          }
        }

        setPrefs('order', order, enc: true);
      }else{
        setPrefs('order', data, enc: true);
      }

      Navigator.pop(context, {'addedToCart': true});
    });
  }

  initData(){
    var data = widget.data;

    for (var i = 0; i < data.length; i++) {
      var o = data[i];
      total += (o['qty'] + (o['qty_pcs'] / o['volume'])) * o['price'];
    }
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Rincian Pembelian', center: true),

      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
              child: text('Daftar Item', bold: true),
            ),

            Expanded(
              child: PreventScrollGlow(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.black12),
                        left: BorderSide(color: Colors.black12),
                        right: BorderSide(color: Colors.black12),
                      )
                    ),
                    child: Column(
                      children: <Widget>[

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(widget.data.length, (i){
                            var data = widget.data[i];

                            return Container(
                              padding: EdgeInsets.all(10), width: Mquery.width(context),
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? TColor.silver() : Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        text(data['name'], overflow: TextOverflow.ellipsis),
                                        text(nformat(data['price']))
                                      ],
                                    )
                                    
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: text(data['qty'].toString()+'/'+data['qty_pcs'].toString(), bold: true)
                                  )
                                ],
                              )
                            );
                          }),
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  text('TOTAL PEMBAYARAN'),
                  text('Rp '+ nformat(total.toString(), fixed: 0), bold: true),
                ],
              )
            ),
            
            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [

                  Button(
                    onTap: isSubmit || isSave ? null : (){ submit(); },
                    text: 'Order Sekarang', isSubmit: isSubmit,
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Button(
                      color: Color.fromRGBO(255, 255, 255, isSave ? .5 : 1), textColor: Colors.black87,
                      onTap: isSave || isSubmit ? null : (){ save(); },
                      text: 'Simpan', isSubmit: isSave, spinColor: TColor.azure(),
                    )
                    
                    // WidSplash(
                    //   onTap: (){
                    //     setPrefs('order', widget.data, enc: true);
                    //     Navigator.pop(context, {'savedToLocal': true});
                    //   },
                    //   color: Colors.white,
                    //   child: Container(
                    //     padding: EdgeInsets.all(11), width: Mquery.width(context),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black12)
                    //     ),
                    //     child: text('Simpan', align: TextAlign.center),
                    //   ),
                    // ),
                  ),

                ]
              )
            )
          ],
        ),
      ),
    );
  }
}