import 'package:dagink/screens/dashboard/purchase/detail-stock.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  Stock(this.ctx);

  final ctx;

  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {

  bool loading = false;
  List purchases = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
    });

    String uid = await Auth.id();

    Http.get('stocks/'+uid, then: (_, data){
      Map res = decode(data);
      purchases = filter = res['data'];

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
      appBar: Wh.appBar(context, title: 'Stock Saya', center: true),

      body: loading ? ListSkeleton(length: 15,) : filter.length == 0 ?

        RefreshIndicator( onRefresh: () async{  getData();  },
        child: Center(
          child: PreventScrollGlow(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Wh.noData(message: 'Anda tidak memiliki data stock')
              ],
            ),
          ),
        )
      ) :
      
       ListView.builder(
        itemCount: filter.length,
        itemBuilder: (BuildContext context, i){
          var data = filter[i];

          return WidSplash(
            padding: EdgeInsets.all(15),
            color: i % 2 == 0 ? TColor.silver() : Colors.white,
            onTap: (){
              Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => DetailStock(data: data)));
            },
            onLongPress: (){
              Wh.options(widget.ctx, options: ['Edit Harga'], icons: [Ln.edit()], then: (res){

              });
            },
            child: Container(
              child: Row(
                children: <Widget>[

                  data['image'] == 'default.png' ?

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/no-img.png')
                      )
                    ),
                  ) :

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: FadeInImage.assetNetwork(
                      height: 50, width: 50,
                      placeholder: 'assets/img/no-img.png',
                      image: Http.baseUrl(url: 'product_image/'+data['image']),
                    ),
                  ),

                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              text(ucwords(data['name']), bold: true, overflow: TextOverflow.ellipsis),
                              text(data['code'])
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              text(data['stock_qty']+' / '+data['stock_pcs'], bold: true),
                            ],
                          )
                        )
                      ],
                    ),
                  )

                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}