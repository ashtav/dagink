import 'package:dagink/services/api/api.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class PurchaseOrder extends StatefulWidget {
  @override
  _PurchaseOrderState createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {

  bool loading = false;

  List orders = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Request.get('purchase?created_by='+uid, then: (_, data){
      Map res = decode(data);
      orders = filter = res['data']; print(res);

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
    return loading ? ListSkeleton(length: 15) : filter.length == 0 ? Wh.noData(message: 'Anda tidak memiliki transaksi dalam proses\nTap + untuk menambahkan') : 
    
    ListView.builder(
      itemCount: filter.length,
      itemBuilder: (BuildContext context, i){
        return WidSplash(
          onTap: (){

          },
          child: Container(
            child: text('lorem')
          ),
        );
      },
    );
  }
}