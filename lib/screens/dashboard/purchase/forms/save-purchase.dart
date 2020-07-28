import 'dart:io';

import 'package:dagink/services/api/api.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class SavePurchase extends StatefulWidget {
  SavePurchase(this.ctx, {this.data});

  final ctx, data;

  @override
  _SavePurchaseState createState() => _SavePurchaseState();
}

class _SavePurchaseState extends State<SavePurchase> {

  bool isSubmit = false, isSave = false;
  int total = 0;

  submit({bool statusInput: false}){

  }

  save() async{

    setState(() {
      isSave = true;
    });

    // Uri uri = Uri.parse('https://daging-dev.bukakode.com/purchase');
    // http.MultipartRequest request = new http.MultipartRequest('POST', uri);

    List formData = [];

    for (var i = 0; i < widget.data.length; i++) {
      var data = widget.data[i];

      // formData.append('items['+i.toString()+'].product_id', data['product_id']);
      // formData.append('items['+i.toString()+'].qty', data['qty']);
      // formData.append('items['+i.toString()+'].qty_pcs', data['qty_pcs']);
      formData.add({
        'product_id': data['product_id'].toString(),
        'qty': data['qty'].toString(),
        'qty_pcs': data['qty_pcs'].toString()
      });

      // request.fields['items['+i.toString()+'].product_id'] = data['product_id'].toString();
      // request.fields['items['+i.toString()+'].qty'] = data['qty'].toString();
      // request.fields['items['+i.toString()+'].qty_pcs'] = data['qty_pcs'].toString();
    }

    // print(request.fields);

    

    // var data = encode({'name': 'sdfsf', 'email': 'sfsdf'});

    // print(encode(formData));

    // String token = await Auth.token();

    // Map<String, String> headers = { HttpHeaders.authorizationHeader : token, 'Accept': 'application/json'};

    // request.headers.addAll(headers);

    // http.StreamedResponse response = await request.send();
    // print(response.statusCode);
    // print(response.headers);
    // print(response.stream); 'items' = [{}]

    var _data = {'items': formData}; print(encode(_data));


    // try {
    //   http.post('https://daging-dev.bukakode.com/purchase', body: encode(_data), headers: { HttpHeaders.authorizationHeader: token, 'Content-Type': 'application/json'}).then((res){

    //     // if(res.statusCode != 200 && res.statusCode != 201){
    //     //   var response = {'status': res.statusCode, 'body': decode(res.body)};
          
    //     // }else{
          
    //     // }

    //     print(res.body);

    //   });
    // } catch (e) {
    //   if(e is PlatformException) {
    //     Wh.toast(e.message);
    //   }
    // }

    // setState(() => isSave = false );


    



    Request.post('purchase', formData: encode(_data), debug: true, then: (_, data){
      setState(() => isSave = false );
      Navigator.pop(context, {'added': true});
    }, error: (err){
      setState(() => isSave = false );
      onError(context, response: err);
    });
  }

  initData(){
    var data = widget.data;

    for (var i = 0; i < data.length; i++) {
      total += data[i]['price'];
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
                                    child: text(data['qty']+'/'+data['qty_pcs'], bold: true)
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
                  text('Rp '+ nformat(total.toString()), bold: true),
                ],
              )
            ),
            
            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [

                  Button(
                    onTap: isSubmit ? null : (){ submit(); },
                    text: 'Order Sekarang', isSubmit: isSubmit,
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Button(
                      color: Color.fromRGBO(255, 255, 255, isSave ? .5 : 1), textColor: Colors.black87,
                      onTap: isSave ? null : (){ save(); },
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