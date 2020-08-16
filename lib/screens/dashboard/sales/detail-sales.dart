import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:dagink/widgets/modal.dart';
import 'package:dagink/widgets/printer.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class DetailSales extends StatefulWidget {
  DetailSales(this.ctx, {this.data});
  
  final ctx, data;

  @override
  _DetailSalesState createState() => _DetailSalesState();
}

class _DetailSalesState extends State<DetailSales> {

  bool loading = true;

  List items = [];

  Map sales = {};

  int totalQty = 0, totalPcs = 0;

  getDetailPenjualan() async{
    setState(() {
      loading = true;
    });

    var data = widget.data;

    Http.get('sales/'+data['id'].toString(), then: (_, data){
      var res = decode(data)['data'];

      items = res['details'];
      sales = res;

      totalQty = 0; totalPcs = 0;

      for (var i = 0; i < items.length; i++) {
        totalQty += items[i]['qty'];
        totalPcs += items[i]['qty_pcs'];
      }

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err);
    });
  }

  @override
  void initState() {
    super.initState(); getDetailPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: Column(
        children: <Widget>[
          text(widget.data['store_name'], size: 18),
          text(widget.data['transaction_date'], size: 12)
        ],
      )
      , center: true, actions: [
        IconButton(
          icon: Icon(Ln.infoCircle()),
          onPressed: (){
            Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => InfoPenjualan(sales)));
          },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                getDetailPenjualan();
              },
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, i){
                  var data = items[i];

                  return Container(
                    padding: EdgeInsets.all(15),
                    color: i % 2 == 0 ? TColor.silver() : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(data['product_code'].toString()+' - '+data['product_name'], bold: true),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            text(nformat(data['sale_price'])),
                            text(data['qty'].toString()+'/'+data['qty_pcs'].toString())
                          ],
                        )
                      ]
                    )
                  );
                }
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 0, top: 0, bottom: 0),
                decoration: BoxDecoration(
                  color: TColor.azure(),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text('Grand Total : '+nformat(widget.data['grand_total']).toString(), color: Colors.white, bold: true),
                        text('Total Qty/Pcs : '+totalQty.toString()+' / '+totalPcs.toString(), color: Colors.white, size: 14),
                      ],
                    ),

                    WidSplash(
                      padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
                      onTap: (){

                        Modal.bottom(widget.ctx, child: Printer(print: (b){ print(b);
                          PrintSales(data: sales).run();
                        }), wrap: true);

                      },
                      child: Icon(Ln.print(), color: Colors.white,),
                      color: TColor.blue(o: .3),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

class InfoPenjualan extends StatefulWidget {
  InfoPenjualan(this.data);

  final data;

  @override
  _InfoPenjualanState createState() => _InfoPenjualanState();
}

class _InfoPenjualanState extends State<InfoPenjualan> {

  List labels = [
    'Kode', 'Nama Toko', 'Tanggal Transaksi', 'Catatan'
  ], values = [];

  initData(){
    var data = widget.data;
    values.add(data['code']);
    values.add(data['store_name']);
    values.add(data['transaction_date']);
    values.add(data['note']);
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Informasi Penjualan', center: true),

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
                  text(values[i]),
                ]
              ),
            );
          }),
        ),
      ),


    );
  }
}

class PrintSales {
  PrintSales({this.data});
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;


  final data;

  run(){
    bluetooth.isConnected.then((isConnected) async{
      if(isConnected){

        List detail = data['details']; print(detail);

        bluetooth.printCustom("PT. KEMBAR PUTRA MAKMUR",1,1);
        bluetooth.printCustom("Jl. Anggrek I No. 1, Kapal, Mengwi, Badung",0,1);
        bluetooth.printCustom("(0361) 9006481 | www.kembarputra.com",0,1);

        bluetooth.printCustom("------------------------------------------",0,1);

        bluetooth.printLeftRight('Kode : '+data['code'].toString(), '     Tgl. '+data['transaction_date'],0);
        bluetooth.printCustom('Kode Toko : '+data['store_code'].toString(),0,0);
        bluetooth.printCustom('Penjual : '+data['name'],0,0);
        bluetooth.printCustom("------------------------------------------",0,1);

        double grandTotal = 0;

        for (var i = 0; i < detail.length; i++) {
          var item = detail[i], qty = item['qty'].toString(), pcs = item['qty_pcs'].toString();

          bluetooth.printCustom(item['product_code']+' - '+item['product_name'],0,0);
          bluetooth.printLeftRight(qty+'/'+pcs, nformat(item['sale_price'])+'         '+Cur.rupiah(item['subtotal']), 0);

          grandTotal += item['subtotal'];
        }

        bluetooth.printCustom("------------------------------------------",0,1);

        bluetooth.printLeftRight('Total : ', Cur.rupiah(grandTotal), 0);
        bluetooth.printLeftRight('Grand Total : ', Cur.rupiah(grandTotal), 0);

        bluetooth.printNewLine();
        bluetooth.printCustom('Harga sudah termasuk PPN',0,1);
        bluetooth.printCustom('--== Terima Kasih ==--',0,1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }
  
}