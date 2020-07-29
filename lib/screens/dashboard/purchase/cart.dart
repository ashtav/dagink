import 'package:dagink/screens/dashboard/purchase/detail-cart.dart';
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

  List carts = [], filter = [];

  double total = 0.0;

  int list = -1;

  getData() async{
    setState(() {
      loading = true;
    });

    // String uid = await Auth.id();

    // Http.get('purchase?created_by='+uid, then: (_, data){
    //   Map res = decode(data);
    //   carts = filter = res['data']; print(res);

    //   setState(() => loading = false );
    // }, error: (err){
    //   setState(() => loading = false );
    //   onError(context, response: err, popup: true);
    // });

    getPrefs('order', dec: true).then((res){
      if(res != null){
        carts = filter = res; //print(res);
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
            'qty_pcs': data['qty_pcs'].toString()
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
                  carts = filter = [];
                });
              }
            });
          },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? 

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
              itemCount: filter.length,
              itemBuilder: (BuildContext context, i){
                var data = filter[i];

                return GestureDetector(
                  onTapDown: (e){
                    // setState(() {
                    //   list = -1;
                    // });
                  },
                  onHorizontalDragUpdate: (e){
                    print(e.delta.dx);
                    if(e.delta.dx < -3){
                      setState(() {
                        list = i;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                          
                      Container(
                        // onTap: (){
                        //   // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailCart(widget.ctx, data: data)));
                        // },
                        padding: EdgeInsets.all(15), color: i % 2 == 0 ? TColor.silver() : Colors.white,
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

                      AnimatedPositioned(
                        right: list == i ? 0 : -150,
                        duration: Duration(milliseconds: 300),
                        child: Container(
                          child: Row(
                            children: List.generate(2, (i){
                              List icons = [Ln.edit(), Ln.trash()];

                              return WidSplash(
                                onTap: (){ },
                                color: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12)
                                  ),
                                  child: Icon(icons[i]),
                                ),
                              );
                            })
                          ),
                        ),
                      )
                    ]
                  )
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