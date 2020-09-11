import 'package:dagink/components/components.dart';
import 'package:dagink/screens/dashboard/home/achievement.dart';
import 'package:dagink/screens/dashboard/home/report.dart';
import 'package:dagink/screens/dashboard/sales/sales.dart';
import 'package:dagink/screens/dashboard/stock/purchase.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home(this.ctx);

  final ctx;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isLoadAchievement = true, loading = false;

  int penjualanHariIni = 0, pembelianHariIni = 0;

  var user = {};

  initAuth() async{
    var auth = await Auth.user();

    setState(() {
      user = auth;
    });
  }

  initHome() async{
    setState(() => loading = true );

    _purchase(){
      Http.get('purchase/get/purchase_by_date', then: (_, data){
        Map result = decode(data);
        penjualanHariIni = result['count'];

        getProfile();

      }, error: (err){
        setState(() => loading = false );
        onError(context, response: err);
      });

    }

    Http.get('sales/get/sales_by_date', then: (_, data){
      Map result = decode(data);
      pembelianHariIni = result['count'];

      _purchase();

    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err);
    });
  }

  // getAchievement() async{
  //   Http.get('user/program/achievement', then: (_, data){
      
  //     setState(() => isLoadAchievement = false );
  //   }, error: (err){
  //     setState(() => loading = false );
  //     onError(context, response: err);
  //   });
  // }

  getProfile() async{

    Http.get('me', then: (_, data) async{
      setState(() => loading = false );

      setPrefs('user', data);

      setState(() {
        loading = false;
        user = decode(data);
      });
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err);
    });
  }

  @override
  void initState() {
    super.initState(); initHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.silver(),
      appBar: Wh.appBar(context, title: 'Home', center: true, back: false),

      body: RefreshIndicator(
        onRefresh: () async{
          initHome();
        },
        child: ListView(
          children: [

              Alert(
                text('Selamat datang di Dagink', 
                color: Colors.white), color: TColor.azure(), 
                icon: Icon(Ln.smile(), color: Colors.white),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(3)
                ),
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: loading ? Wh.spiner() : Icon(Ln.wallet())
                        ),

                        text(Cur.rupiah(user['balance'] ?? 0), size: 20, bold: true)
                      ],
                    ),
                    text('Jumlah saldo Anda saat ini', color: Colors.black38)
                  ],
                ),
              ),
             

              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: List.generate(2, (i) {
                        List heights = [130.0, 130.0],
                              labels = ['Point','Laporan'],
                              icons = [Ln.star(), Ln.doc()];

                        return Container(
                            margin: EdgeInsets.all(2),
                            height: heights[i],
                            width: Mquery.width(context) / 2 - 19,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(3)
                            ),
                            child: WidSplash(
                              padding: EdgeInsets.all(15),
                              color: Colors.white,
                              onTap: (){
                                switch (i) {
                                  case 0: Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Achievement(widget.ctx))); break;
                                  default: Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Report(widget.ctx))); break;
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  text(labels[i]),

                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Icon(icons[i], size: 35),
                                        )
                                      ]
                                    )
                                  )
                                  
                                ]
                              ),
                            )
                            
                        );
                      })
                    ),

                    Column(
                      children: List.generate(2, (i) {
                        List heights = [130.0, 130.0],
                            labels = ['Pembelian','Penjualan'],
                            values = [penjualanHariIni,pembelianHariIni];

                        return Container(
                          margin: EdgeInsets.all(2),
                          height: heights[i],
                          width: Mquery.width(context) / 2 - 19,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: WidSplash(
                            padding: EdgeInsets.all(15),
                            color: Colors.white,
                            onTap: (){
                              switch (i) {
                                case 0: Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Purchase(widget.ctx))); break;
                                default: Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Sales(widget.ctx, isBack: true,))); break;
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                text(labels[i]),

                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: text(values[i], size: 35, bold: true),
                                      )
                                    ]
                                  )
                                )
                                
                              ]
                            ),
                          )
                        );
                      })
                    )
                  ],
                ),
              )

            ],
          ),
      )
    );
  }
}