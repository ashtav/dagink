import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  Cart(this.ctx);

  final ctx;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  bool loading = false, isSubmit = false;

  List carts = [];

  double total = 0.0;

  int list = -1;

  getData() async{
    setState(() {
      loading = true;
    });

    // String uid = await Auth.id();

    // Http.get('purchase?created_by='+uid, then: (_, data){
    //   Map res = decode(data);
    //   carts = carts = res['data']; print(res);

    //   setState(() => loading = false );
    // }, error: (err){
    //   setState(() => loading = false );
    //   onError(context, response: err, popup: true);
    // });

    getPrefs('order', dec: true).then((res){
      if(res != null){
        carts = res; //print(res);
        initData(res);
      }

      setState(() => loading = false );
    });
  }

  initData(data){
    total = 0;
    for (var i = 0; i < data.length; i++) {
      var o = data[i];
      total += (o['qty'] + (o['qty_pcs'] / o['volume'])) * o['price'];
    }
  }

  submit(){
    getPrefs('order', dec: true).then((res){
      if(res != null){
        setState(() {
          isSubmit = true;
        });

        List formData = [];

        for (var i = 0; i < res.length; i++) {
          var data = res[i];

          formData.add({
            'product_id': data['product_id'].toString(),
            'qty': data['qty'].toString(),
            'qty_pcs': data['qty_pcs'].toString(),
            'discount': 0
          });
        }

        var _data = {'items': formData};

        Http.post('purchase', data: encode(_data), debug: true, header: {'Content-Type': 'application/json'}, then: (_, data){
          setState(() => isSubmit = false );
          removePrefs(list: ['order']);

          Navigator.pop(context, {'added': true});
        }, error: (err){
          setState(() => isSubmit = false );
          onError(context, response: err);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState(); getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Keranjang', center: true, actions: [
        carts.length == 0 ? SizedBox.shrink() : IconButton(
          icon: Icon(Ln.trash(), color: Colors.red),
          onPressed: carts.length == 0 ? null : (){
            Wh.confirmation(widget.ctx, message: 'Yakin ingin mmenghapus semua barang ini?', confirmText: 'Hapus Barang', then: (res){
              if(res == 0){
                removePrefs(list: ['order']);

                setState(() {
                  carts = carts = [];
                });

                Navigator.pop(widget.ctx);
              }
            });
          },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : carts.length == 0 ? 

        RefreshIndicator( onRefresh: () async{  getData();  },
          child: Center(
            child: PreventScrollGlow(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Wh.noData(message: 'Anda tidak memiliki barang yang disimpan')
                ],
              ),
            ),
          )
        ) :
      
      Column(
        children: [

          Expanded(
            child: RefreshIndicator(
            onRefresh: () async{
              getData();
            },
            child: ListView.builder(
              itemCount: carts.length,
              itemBuilder: (BuildContext context, i){
                var data = carts[i];

                return WidSplash(
                  onTap: (){
                    Wh.options(widget.ctx, options: ['Edit','Hapus'], icons: [Ln.edit(), Ln.trash()], danger: [1], then: (res){
                      Navigator.pop(widget.ctx);

                      switch (res) {
                        case 0:
                          modal(widget.ctx, child: EditQty(data: data), wrap: true, then: (value){
                            if(value != null) setState(() {
                              data['qty'] = value['item']['qty'];
                              data['qty_pcs'] = value['item']['qty_pcs'];

                              initData(carts);

                              setPrefs('order', carts, enc: true);
                            });
                          });
                          
                          break;
                        default:
                          setState((){
                            carts.removeWhere((item) => item['product_id'] == data['product_id']);
                            initData(carts);

                            if(carts.length == 0){
                              removePrefs(list: ['order']);
                            }else{
                              setPrefs('order', carts, enc: true);
                            }

                          });
                          break;
                      }
                    });
                  },
                  color: i % 2 == 0 ? TColor.silver() : Colors.white,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text(data['name'], bold: true),
                              text('Jumlah : '+data['qty'].toString()+' / '+data['qty_pcs'].toString())

                            ]
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              text(nformat(data['price']))
                            ]
                          ),
                        ),

                      ],
                    )
                  ),
                );
              },
            ),
          )
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

class EditQty extends StatefulWidget {
  EditQty({this.data});

  final data;

  @override
  _EditQtyState createState() => _EditQtyState();
}

class _EditQtyState extends State<EditQty> {

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
    if(widget.data != null){
      var data = widget.data;

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
    return Column(
      children: <Widget>[
        Material(
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: text(widget.data['name'])
                    )
                  ],
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

                Button(
                  onTap: (){
                    if(qty.text == '0' && pcs.text == '0'){
                      Wh.toast('Inputkan jumlah pembelian');
                    }else{
                      Navigator.pop(context, {'item': {'product_id': widget.data['id'], 'qty': int.parse(qty.text), 'qty_pcs': int.parse(pcs.text), 'name': widget.data['name'], 'price': widget.data['price'], 'volume': widget.data['volume']}});
                    }
                  },
                  text: 'OK',
                ),

              ],
            ),
          ),
        )
      ],
    );
  }
}