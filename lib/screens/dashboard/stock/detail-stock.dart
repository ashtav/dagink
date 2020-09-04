import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';

class DetailStock extends StatefulWidget {

  DetailStock({this.data});

  final data;

  @override
  _DetailStockState createState() => _DetailStockState();
}

class _DetailStockState extends State<DetailStock> {

  List labels = ['Kode Barang','Nama Barang','Rekomendasi Harga','Harga Jual','Satuan','Volume','Jumlah Qty','Jumlah Pcs','Total Karton','Nilai Stock'],
        keys = ['code','name','recommended_sale_price','sale_price','unit','volume','stock_qty','stock_pcs','total_carton','value_stock'],
        values = [];

  initData(){
    var data = widget.data; print(data);

    for (var i = 0; i < keys.length; i++) {
      List _ = ['recommended_sale_price','sale_price','value_stock'];
      values.add(_.indexOf(keys[i]) > -1 ? nformat(data[keys[i]]) : data[keys[i]]);
    }
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Detail Stock', center: true),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(labels.length, (i){
            return Container(
              width: Mquery.width(context),
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(labels[i], bold: true),
                  text(values.length <= i ? '' : values[i])
                ]
              ),
            );
          }),
        ),
      ),
    );
  }
}