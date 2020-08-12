import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormItem extends StatefulWidget {
  FormItem(this.ctx);

  final ctx;

  @override
  _FormItemState createState() => _FormItemState();
}

class _FormItemState extends State<FormItem> {

  var product = TextEditingController(),
      qty = TextEditingController(text: '0'),
      pcs = TextEditingController(text: '0'),
      salesPrice = TextEditingController();

  String productId;
  var dataProduct;

  _save() async{ //removePrefs(list: ['items']);
    if(productId == null || qty.text.isEmpty && pcs.text.isEmpty || salesPrice.text.isEmpty || qty.text == '0' && pcs.text == '0'){
      Wh.toast('Lengkapi form');
    }else{
      var items = await LocalData.get('items');

      List listItem = [];

      var formData = {'product': dataProduct, 'qty': qty.text, 'qty_pcs': pcs.text, 'sales_price': salesPrice.text};

      if(items == null){
        listItem.add(formData);
      }else{
        listItem = decode(items);
        listItem.add(formData);
      }

      setPrefs('items', encode(listItem));

      Navigator.pop(context, {'added': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: 'Tambah Barang', center: true),

        body: Column(
          children: <Widget>[

            Expanded(
              child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [

                  SelectInput(
                    label: 'Pilih Barang', hint: 'Pilih barang',
                    controller: product, select: (){
                      modal(widget.ctx, child: ListProduct(), then: (res){
                        if(res != null){
                          dataProduct = res;
                          
                          setState(() {
                            productId = res['id'].toString();
                            product.text = res['name'];
                            salesPrice.text = res['sale_price'].toString();
                          });
                        }
                      });
                    },
                  ),

                  TextInput(
                    controller: qty, type: TextInputType.datetime,
                    label: 'Qty', hint: 'Jumlah Qty', length: 11,
                  ),

                  TextInput(
                    controller: pcs, type: TextInputType.datetime,
                    label: 'Pcs', hint: 'Jumlah Pcs', length: 11,
                  ),

                  TextInput(
                    controller: salesPrice, type: TextInputType.datetime,
                    label: 'Harga Jual', hint: 'Harga jual', length: 11,
                  )

                ]
              ),
            )
            ),

            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [

                  Button(
                    onTap: (){ _save(); },
                    text: 'Simpan',
                  ),

                ]
              )
            )

          ]
        )
      ),
    );
  }
}

class ListProduct extends StatefulWidget {
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {

  bool loading = false;

  List products = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Http.get('stocks/'+uid, then: (_, data){
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
    return Scaffold(
      appBar: Wh.appBar(context, title: Fc.search(hint: 'Ketik kode atau nama barang', change: (String s){
        String k = s.toLowerCase();

        setState(() {
          filter = products.where((item) => item['code'].toString().toLowerCase().contains(k) || item['name'].toString().toLowerCase().contains(k)).toList();
        });
      })),

      body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Tidak ada data barang\nCoba refresh kembali') :

        RefreshIndicator(
          onRefresh: () async { getData(); },
          child: ListView.builder(
            itemCount: filter.length,
            itemBuilder: (BuildContext context, i){
              var data = filter[i];

              return WidSplash(
                onTap: (){
                  Navigator.pop(context, data);
                },
                color: i % 2 == 0 ? TColor.silver() : Colors.white,
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(data['code']+' - '+data['name']),
                  ]
                )
              );
            }
          ),
        )
    );
  }
}