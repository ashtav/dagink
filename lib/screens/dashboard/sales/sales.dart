import 'package:dagink/screens/dashboard/sales/detail-sales.dart';
import 'package:dagink/screens/dashboard/sales/forms/form-sale.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';


/*  NOTE

    - lib
      - controllers
        - salesController.dart -> create, read, update, delete
      - screens
        - sales.dart


*/

class Sales extends StatefulWidget {
  Sales(this.ctx);

  final ctx;

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {

  List sales = [];

  bool loading = true;

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Http.get('sales?created_by='+uid, then: (_, data){
      var res = decode(data)['data'];
      sales = res;

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err);
    });
  }

  @override
  void initState() {
    super.initState(); getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Penjualan', back: false, center: true, actions: [
        IconButton(
          icon: Icon(Ln.refresh()),
          onPressed: (){
            getData();
          },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : sales.length == 0 ? Wh.noData(message: 'Tidak ada data penjualan') :

      RefreshIndicator(
        onRefresh: () async{ getData(); },
        child: ListView.builder(
          itemCount: sales.length,
          itemBuilder: (BuildContext context, i){
            var data = sales[i];

            return WidSplash(
              onTap: (){
                Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => DetailSales(widget.ctx, data: data)));
              },
              onLongPress: (){
                Wh.options(widget.ctx, options: ['Cetak Penjualan', 'Hapus Penjualan'], icons: [Ln.print(), Ln.trash()], danger: [1], then: (res){
                  switch (res) {
                    case 0:
                      
                      break;
                    default:
                      Navigator.pop(widget.ctx);
                      Wh.confirmation(widget.ctx, message: 'Yakin ingin menghapus penjualan ini?', confirmText: 'Hapus Penjualan', then: (res){
                        if(res == 0){
                          Navigator.pop(widget.ctx);

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            child: OnProgress()
                          );

                          Http.delete('sales/'+data['id'].toString(), then: (_, data){
                            Navigator.pop(widget.ctx);
                            Wh.toast('Berhasil dihapus');

                          }, error: (err){
                            Navigator.pop(widget.ctx);
                            onError(context, response: err);
                          });

                        }
                      });
                  }
                });

              },
              padding: EdgeInsets.all(15),
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text(data['code'], bold: true),
                      text(data['store_name'])
                    ],
                  ),

                  text(data['transaction_date'])

                ],
              )
              
              
            );
          },
          
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.azure(),
        heroTag: 'sale',
        child: Icon(Ln.plus()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormSale(widget.ctx))).then((res){
            if(res != null){
              removePrefs(list: ['items']);
              Wh.toast('Penjualan berhasil ditambahkan');
            }
          });
        },
      ),
    );
  }
}