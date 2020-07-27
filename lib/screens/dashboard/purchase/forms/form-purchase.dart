import 'package:dagink/services/api/api.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormPurchase extends StatefulWidget {
  FormPurchase(this.ctx);

  final ctx;

  @override
  _FormPurchaseState createState() => _FormPurchaseState();
}

class _FormPurchaseState extends State<FormPurchase> {

  bool loading = false;

  List products = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    Request.get('product', then: (_, data){
      Map res = decode(data);
      products = filter = res['data']; print(res);

      setState(() => loading = false );
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
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: Fc.search(
          hint: 'Ketik nama item',
          length: 50, submit: (String s){ Navigator.pop(context, s); },
          action: TextInputAction.go,
        ),),

        body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Tidak ada data product\nCoba refresh kembali') :

          Column(
            children: [

              Expanded(
                child:  ListView.builder(
                  itemCount: filter.length,
                  itemBuilder: (BuildContext context, i){
                    var data = filter[i];

                    return WidSplash(
                      padding: EdgeInsets.all(15),
                      color: i % 2 == 0 ? TColor.silver() : Colors.white,
                      onTap: (){
                        modal(widget.ctx, wrap: true, child: ItemSelection(data: data));
                      },
                      child: Container(
                        child: Row(
                          children: <Widget>[

                            data['image'] == 'default.png' ?

                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/img/no-img.png')
                                )
                              ),
                            ) :

                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: FadeInImage.assetNetwork(
                                height: 50, width: 50,
                                placeholder: 'assets/img/no-img.png',
                                image: Request.baseUrl()+'/product_image/'+data['image'],
                              ),
                            ),

                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      text(ucwords(data['name']), bold: true),
                                      text(data['description'])
                                    ],
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(left: 15),
                                    child: text(nformat(data['price']), bold: true)
                                  )
                                ],
                              ),
                            )

                            
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ]
          ),
        
      ),
    );
  }
}

class ItemSelection extends StatefulWidget {
  ItemSelection({this.data});

  final data;

  @override
  _ItemSelectionState createState() => _ItemSelectionState();
}

class _ItemSelectionState extends State<ItemSelection> {


  var qty = TextEditingController(text: '0'),
      pcs = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5)
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          children: <Widget>[

            Container(
              child: Row(
                children: <Widget>[

                  widget.data['image'] == 'default.png' ?

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/no-img.png')
                      )
                    ),
                  ) :

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: FadeInImage.assetNetwork(
                      height: 50, width: 50,
                      placeholder: 'assets/img/no-img.png',
                      image: Request.baseUrl()+'/product_image/'+widget.data['image'],
                    ),
                  ),

                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(ucwords(widget.data['name']), bold: true),
                            text(widget.data['description'])
                          ],
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: text(nformat(widget.data['price']), bold: true)
                        )
                      ],
                    ),
                  )

                  
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [

                  Expanded(
                    child: TextInput(
                      hint: 'Jumlah dus', controller: qty, type: TextInputType.datetime, length: 11, space: 0,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 11),
                    child: WidSplash(
                      onTap: (){ },
                      child: Icon(Ln.minus()), radius: BorderRadius.circular(50),
                      padding: EdgeInsets.all(11),
                    ),
                  ),

                  WidSplash(
                    onTap: (){ },
                    child: Icon(Ln.plus()), radius: BorderRadius.circular(50),
                    padding: EdgeInsets.all(11),
                  )

                ]
              )
            ),

            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Row(
                children: [

                  Expanded(
                    child: TextInput(
                      hint: 'Jumlah pcs', controller: qty, type: TextInputType.datetime, length: 11, space: 0,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 11),
                    child: WidSplash(
                      onTap: (){ },
                      child: Icon(Ln.minus()), radius: BorderRadius.circular(50),
                      padding: EdgeInsets.all(11),
                    ),
                  ),

                  WidSplash(
                    onTap: (){ },
                    child: Icon(Ln.plus()), radius: BorderRadius.circular(50),
                    padding: EdgeInsets.all(11),
                  )

                ]
              )
            ),

            Row(
              children: <Widget>[

                Container(
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: WidSplash(
                    padding: EdgeInsets.all(9),
                    onTap: (){ },
                    child: Icon(Ln.trash(), color: Colors.redAccent), radius: BorderRadius.circular(3),
                  ),
                ),

                Expanded(
                  child: Button(
                    onTap: (){ },
                    text: 'Tambahkan Ke Keranjang',
                  ),
                ),

              ],
            )

            

          ],
        ),
      ),
    );
  }
}