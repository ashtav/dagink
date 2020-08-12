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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: ucwords(widget.data['store']), center: true),

      body: items.length == 0 ? Wh.noData(message: 'Tidak ada data barang\nTambahkan barang yang dijual') : 

        ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, i){
            var data = items[i];

            print(data);

            return WidSplash(
              onTap: (){ },
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(data['product']['code']+' - '+data['product']['name'], bold: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(nformat(data['product']['sale_price'])),
                        text(data['qty']+'/'+data['qty_pcs'])
                      ],
                    )
                  ]
                )
              ),
            );
          }
        ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: TColor.azure(),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormItem(widget.ctx))).then((res) async{
            if(res != null){
              var listItem = await LocalData.get('items');
              setState(() {
                items = decode(listItem);
              });
            }
          });
        },
        child: Icon(Ln.plus()),
      ),
    );
  }
}
