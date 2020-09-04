import 'package:dagink/screens/dashboard/sales/forms/sale-select-item.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormSale extends StatefulWidget {
  FormSale(this.ctx);

  final ctx;

  @override
  _FormSaleState createState() => _FormSaleState();
}

class _FormSaleState extends State<FormSale> {

  var store = TextEditingController(),
      note = TextEditingController();
    
  String storeId;

  selectItem(){
    if(storeId == null){
      Wh.toast('Anda belum memilih toko');
    }else{
      removePrefs(list: ['items']);
      
      var formData = {
        'store_id': storeId,
        'store': store.text,
        'note': note.text
      };

      Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => SaleSelectItem(widget.ctx, data: formData))).then((res){
        if(res != null){
          Navigator.pop(context, {'added': true});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Penjualan Baru', center: true),

      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [

                  SelectInput(
                    label: 'Pilih Toko', hint: 'Pilih toko',
                    controller: store, select: (){
                      modal(widget.ctx, child: ListToko(), then: (res){
                        if(res != null){
                          setState(() {
                            storeId = res['id'].toString();
                            store.text = res['name'];
                          });
                        }
                      });
                    },
                  ),

                  TextInput(
                    label: 'Catatan', hint: 'Input catatan',
                    controller: note,
                  )

                ]
              ),
            ),
          ),

          Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [

                  Button(
                    onTap: (){ selectItem(); },
                    text: 'Inputkan Barang',
                  ),

                ]
              )
          )
        ]
      )
      
      
    );
  }
}

class ListToko extends StatefulWidget {
  @override
  _ListTokoState createState() => _ListTokoState();
}

class _ListTokoState extends State<ListToko> {

  bool loading = true;

  List stores = [], filter = [];

  getData() async{
    String uid = await Auth.id();

    Http.get('store?created_by='+uid, then: (_, data){
      Map res = decode(data);
      stores = filter = res['data'];

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
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: Fc.search(hint: 'Ketik nama toko', change: (String s){
          String k = s.toLowerCase();

          setState(() {
            filter = stores.where((item) => item['name'].toString().toLowerCase().contains(k)).toList();
          });
        })),

        body: loading ? ListSkeleton(length: 15) : filter.length == 0 ?

          RefreshIndicator( onRefresh: () async{  getData();  },
            child: Center(
              child: PreventScrollGlow(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Wh.noData(message: 'Tidak ada data toko\nCoba kata kunci lain atau tambahkan toko baru.')
                  ],
                ),
              ),
            )
          ) :

          RefreshIndicator(
            onRefresh: () async{ getData(); },
            child: ListView.builder(
              itemCount: filter.length,
              itemBuilder: (BuildContext context, i){
                var data = filter[i];

                return WidSplash(
                  onTap: (){
                    Navigator.pop(context, {'name': data['name'], 'id': data['id']});
                  },
                  padding: EdgeInsets.all(15),
                  color: i % 2 == 0 ? TColor.silver() : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(ucwords(data['name']), bold: true),
                      text(ucwords(data['owner']))
                    ]
                  )
                  
                );
              },
            ),
          )

      ),
    );
  }
}