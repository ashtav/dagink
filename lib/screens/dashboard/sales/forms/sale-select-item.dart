import 'package:dagink/screens/dashboard/sales/forms/form-item.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class SaleSelectItem extends StatefulWidget {
    SaleSelectItem(this.ctx, {this.data});

    final ctx, data;

  @override
  _SaleSelectItemState createState() => _SaleSelectItemState();
}

class _SaleSelectItemState extends State<SaleSelectItem> {

  List items = [];

  bool isSubmit = false;

  double grandTotal = 0;

  getData() async{
    var listItem = await LocalData.get('items');

    if(listItem != null){
      setState(() {
        items = decode(listItem);
      });

      for (var i = 0; i < items.length; i++) {
        grandTotal += double.parse(items[i]['subtotal']);
      }
    }
  }

  submit() async{

    isEnabledLocation(getGps: true, then: (res){
      if(res['enabled']){

        var pos = res['position'];

        setState(() {
          isSubmit = true;
        });

        List formData = [];

        for (var i = 0; i < items.length; i++) {
          var data = items[i];

          formData.add({
            'product_id': data['product']['product_id'].toString(),
            'qty': data['qty'].toString(),
            'qty_pcs': data['qty_pcs'].toString(),
            'sales_price': data['sales_price'].toString()
          });
        }

        var _data = {'store_id': widget.data['store_id'], 'note': widget.data['note'], 'latitude': pos.latitude.toString(), 'longitude': pos.longitude.toString(), 'items': formData};

        Http.post('sales', data: encode(_data), debug: true, header: {'Content-Type': 'application/json'}, then: (_, data){
          setState(() => isSubmit = false );
          Navigator.pop(context, {'added': true});
        }, error: (err){
          setState(() => isSubmit = false );
          onError(context, response: err);
        });
      }else{
        Wh.alert(context, icon: Ic.gps(), message: 'Hidupkan GPS atau lokasi Anda untuk dapat menambahkan data penjualan.');
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
      appBar: Wh.appBar(context, title: ucwords(widget.data['store']), center: true, actions: [
        IconButton(
          icon: Icon(Ln.trash(), color: isSubmit || items.length == 0 ? Colors.black38 : Colors.red,),
          onPressed: isSubmit || items.length == 0 ? null : (){
            Wh.confirmation(widget.ctx, message: 'Yakin ingin menghapus semua daftar barang ini?', confirmText: 'Hapus Semua Barang', then: (res){
              if(res == 0){
                removePrefs(list: ['items']);

                setState(() {
                  items = [];
                });

                Navigator.pop(widget.ctx);
              }
            });
          },
        )
      ]),

      body: items.length == 0 ? Wh.noData(message: 'Tidak ada data barang\nTambahkan barang yang dijual') : 

      Column(
        children: [

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                getData();
              },
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, i){
                  var data = items[i];

                  return WidSplash(
                    onTap: (){ },
                    onLongPress: (){
                      Wh.options(widget.ctx, options: ['Edit Barang','Hapus Barang'], icons: [Ln.edit(),Ln.trash()], danger: [1], then: (res){
                        switch (res) {
                          case 0: // edit
                            Navigator.pop(widget.ctx);

                            Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormItem(widget.ctx, data: data))).then((res) async{
                              if(res != null){
                                var data = res['data'];
                                var listItem = await LocalData.get('items');

                                var decodeItem = [];

                                if(listItem != null){
                                  decodeItem = decode(listItem);
                                  decodeItem[i] = data;

                                  setState(() {
                                    items[i] = data;
                                  });
                                }
                                
                              }
                            });
                            break;
                          default: // hapus
                            Navigator.pop(widget.ctx);

                            Wh.confirmation(widget.ctx, message: 'Yakin ingin menghapus barang ini?', confirmText: 'Hapus Barang', then: (res) async{
                              if(res == 0){
                                var listItem = await LocalData.get('items');

                                var decodeItem = [];

                                if(listItem != null){
                                  decodeItem = decode(listItem);
                                  decodeItem.removeWhere((el) => el['product']['product_id'] == data['product']['product_id']);

                                  setPrefs('items', encode(decodeItem));
                                }

                                setState(() {
                                  items.removeWhere((el) => el['product']['product_id'] == data['product']['product_id']);
                                });

                                Navigator.pop(widget.ctx);
                              }
                            });
                        }
                      });
                    },
                    color: i % 2 == 0 ? TColor.silver() : Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text(data['product']['code'].toString()+' - '+data['product']['name'], bold: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              text(nformat(data['product']['sale_price'])),
                              text(data['qty'].toString()+'/'+data['qty_pcs'].toString())
                            ],
                          )
                        ]
                      )
                    ),
                  );
                }
              ),
            ),
          ),

          items.length == 0 ? SizedBox.shrink() : Container(
            margin: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: text('Grand Total : '+Cur.rupiah(grandTotal), bold: true),
                ),

                Button(
                  onTap: (){ submit(); }, isSubmit: isSubmit,
                  text: 'Selesaikan Penjualan',
                ),

              ]
            )
          )

        ]
      ),

        

      floatingActionButton: isSubmit ? null : Container(
        margin: EdgeInsets.only(bottom: items.length == 0 ? 0 : 50),
        child: FloatingActionButton(
          backgroundColor: TColor.azure(),
          heroTag: 'FormItem',
          onPressed:(){
            Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormItem(widget.ctx))).then((res) async{
              if(res != null){
                getData();
              }
            });
          },
          child: Icon(Ln.plus()),
        ),
      ),
    );
  }
}
