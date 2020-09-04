import 'package:dagink/screens/dashboard/stock/forms/save-purchase.dart';
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

    Http.get('product', then: (_, data){
      Map res = decode(data);
      products = filter = res['data']; print(res);

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }

  List selected = [];
  double total = 0, totalQty = 0, totalPcs = 0;

  initFooter(){
    total = 0; totalQty = 0; totalPcs = 0;

    for (var i = 0; i < selected.length; i++) {
      var o = selected[i];
      total += (o['qty'] + (o['qty_pcs'] / o['volume'])) * o['price'];
      totalQty += o['qty'];
      totalPcs += o['qty_pcs'];
    }
  }

  @override
  void initState() {
    super.initState(); getData();
  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        backgroundColor: TColor.silver(),
        appBar: Wh.appBar(context, title: Fc.search(
          hint: 'Ketik nama item',
          length: 50, change: (String s){
            var k = s.toLowerCase();

            setState(() {
              filter = products.where((item) => item['name'].toString().toLowerCase().contains(k)).toList();
            });
          },
          action: TextInputAction.go,
        ),),

        body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Tidak ada data product\nCoba refresh kembali') :

          Stack(
            children: [

              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        getData();
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 70),
                        itemCount: filter.length,
                        itemBuilder: (BuildContext context, i){
                          var data = filter[i];

                          int index = selected.indexWhere((item) => item['product_id'] == data['id']);

                          return WidSplash(
                            padding: EdgeInsets.all(15),
                            color: i % 2 == 0 ? TColor.silver() : Colors.white,
                            onTap: (){

                              modal(widget.ctx, wrap: true, child: ItemSelection(data: data, initData: index > -1 ? selected[index] : null), then: (res){
                                if(res != null){
                                  int io = selected.indexWhere((item) => item['product_id'] == res['item']['product_id']);

                                  if(res['remove'] != null){
                                    setState(() => selected.removeAt(io) );
                                  }else{
                                    setState(() {
                                      if( io > -1 ){
                                        selected[io] = res['item'];
                                      }else{
                                        selected.add(res['item']);
                                      }
                                    });
                                  }

                                  initFooter();
                                }
                              });
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
                                      image: Http.baseUrl(url: 'product_image/'+data['image']),
                                    ),
                                  ),

                                  Flexible(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              text(ucwords(data['name']), bold: true, overflow: TextOverflow.ellipsis),
                                              text(data['description'])
                                            ],
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(left: 15),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                              text(nformat(data['price']), bold: true),
                                              index > -1 ? ZoomIn(child: text(selected[index]['qty'].toString()+'/'+selected[index]['qty_pcs'].toString(), color: Colors.green, bold: true)) : SizedBox.shrink()
                                            ],
                                          )
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
                    ),
                  ),
                ]
              ),

              Positioned(
                bottom: 0,
                child: selected.length == 0 ? SizedBox.shrink() : SlideUp(
                  child: Container(
                    width: Mquery.width(context),
                    padding: EdgeInsets.all(15),
                    child: WidSplash(
                       onTap: (){

                        Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => SavePurchase(widget.ctx, data: selected))).then((value){
                          if(value != null){
                            if(value['addedToCart'] != null){
                              Wh.toast('Disimpan ke keranjang');
                              Navigator.pop(context, {'addedToCart': true});
                            }else if(value['added'] != null){
                              Navigator.pop(context, {'added': true});
                            }
                          }
                        });

                      },
                      color: TColor.azure(), radius: BorderRadius.circular(3),
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(totalQty.toInt().toString()+' / '+totalPcs.toInt().toString()+'  |  '+nformat(total.toString(), fixed: 0), color: Colors.white, bold: true),
                                text('Tap untuk menyelesaikan', color: Colors.white, size: 13)
                              ]
                            ),

                            Icon(Ln.bag(), color: Colors.white,)

                          ],
                        )
                        
                        
                      ),
                    )
                  ),
                ),
              )
            ]
          ),

        // floatingActionButton: selected.length == 0 ? null : FloatingActionButton(
        //   heroTag: 'form-purchase',
        //   child: Icon(Ln.check()),
        //   onPressed: (){
        //     Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => SavePurchase(widget.ctx, data: selected))).then((value){
        //       if(value != null){
                
        //       }
        //     });
        //   },
        // ),
        
      ),
    );
  }
}

class ItemSelection extends StatefulWidget {
  ItemSelection({this.data, this.initData});

  final data, initData;

  @override
  _ItemSelectionState createState() => _ItemSelectionState();
}

class _ItemSelectionState extends State<ItemSelection> {


  var qty = TextEditingController(text: '0'),
      pcs = TextEditingController(text: '0');

  
  _add({TextEditingController controller}){
    var c = controller;

    if(c.text == ''){
      controller.text = '0';
    }else{
      controller.text = (int.parse(c.text) + 1).toString();
    }
  }

  _min({TextEditingController controller}){
    var c = controller;

    if(c.text == '' || c.text == '0'){
      controller.text = '0';
    }else{
      controller.text = (int.parse(c.text) - 1).toString();
    }
  }

  initInput(){
    if(widget.initData != null){
      var data = widget.initData;

      qty.text = data['qty'].toString();
      pcs.text = data['qty_pcs'].toString();
    }
  }

  @override
  void initState() {
    super.initState(); initInput();
  }

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
                      image: Http.baseUrl(url: 'product_image/'+widget.data['image']),
                    ),
                  ),

                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              text(ucwords(widget.data['name']), bold: true, overflow: TextOverflow.ellipsis),
                              text(widget.data['description'])
                            ],
                          ),
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
                      hint: 'Jumlah dus', controller: qty, enabled: false, type: TextInputType.datetime, length: 11, space: 0, prefix: Container(child: text('QTY'), margin: EdgeInsets.only(right: 10),),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 11),
                    child: WidSplash(
                      onTap: (){ _min(controller: qty); },
                      child: Icon(Ln.minus()), radius: BorderRadius.circular(50),
                      padding: EdgeInsets.all(11),
                    ),
                  ),

                  WidSplash(
                    onTap: (){ _add(controller: qty); },
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
                      hint: 'Jumlah pcs', controller: pcs, enabled: false, type: TextInputType.datetime, length: 11, space: 0, prefix: Container(child: text('PCS'), margin: EdgeInsets.only(right: 10),)
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 11),
                    child: WidSplash(
                      onTap: (){ _min(controller: pcs); },
                      child: Icon(Ln.minus()), radius: BorderRadius.circular(50),
                      padding: EdgeInsets.all(11),
                    ),
                  ),

                  WidSplash(
                    onTap: (){ _add(controller: pcs); },
                    child: Icon(Ln.plus()), radius: BorderRadius.circular(50),
                    padding: EdgeInsets.all(11),
                  )

                ]
              )
            ),

            Row(
              children: <Widget>[
                
                widget.initData != null ?
                Container(
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: WidSplash(
                    padding: EdgeInsets.all(9),
                    onTap: (){
                      Navigator.pop(context, {'remove': true, 'item': {'product_id': widget.data['id']}});
                    },
                    child: Icon(Ln.trash(), color: Colors.redAccent), radius: BorderRadius.circular(3),
                  ),
                ) : SizedBox.shrink(),

                Expanded(
                  child: Button(
                    onTap: (){
                      if(qty.text == '0' && pcs.text == '0'){
                        Wh.toast('Inputkan jumlah pembelian');
                      }else{
                        Navigator.pop(context, {'item': {'product_id': widget.data['id'], 'qty': int.parse(qty.text), 'qty_pcs': int.parse(pcs.text), 'name': widget.data['name'], 'price': widget.data['price'], 'volume': widget.data['volume']}});
                      }
                    },
                    text: 'OK',
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