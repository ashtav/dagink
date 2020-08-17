import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Report extends StatefulWidget {
  Report(this.ctx);

  final ctx;

  @override
  _BalanceHistoriesState createState() => _BalanceHistoriesState();
}

class _BalanceHistoriesState extends State<Report> {

  bool loading = true;
  List labels = ['Toko','Invoice','Grand Total','Diskon','Net Sales','Modal','Profit'], values = [];

  getData() async{

    setState(() {
      loading = true;
    });

    Http.get('report/sales', then: (_, data){
      Map res = decode(data);
      values = [];
      
      // achivements = res['data'];
      List keys = ['toko','invoice','grand_total','discount','net_sales','modal','profit'];

      res.forEach((key, value) {
        values.add(res[key]);
      });

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
      appBar: Wh.appBar(context, title: 'Laporan Penjualan', center: true, actions: [
        IconButton(
          icon: Icon(Ln.refresh()),
          onPressed: (){ getData(); },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : 

      RefreshIndicator(
        onRefresh: () async { getData(); },
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(labels.length, (i){
              return Container(
                padding: EdgeInsets.all(15),
                color: i % 2 == 0 ? TColor.silver() : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(labels[i], bold: true),
                    text(values.length <= i ? '-' : values[i])
                  ]
                ),
              );
            })
          ),
        )
      )
    );
  }
}

class DetailAchievement extends StatefulWidget {
  DetailAchievement(this.ctx, {this.data});

  final ctx, data;

  @override
  _DetailAchievementState createState() => _DetailAchievementState();
}

class _DetailAchievementState extends State<DetailAchievement> {

  List labels = ['Nama Program','Milstone Qty','Bonus','Redeem Status','Achivement','Persentase','Timeline','Tanggal'];
  List values = [];

  initData(){
    var data = widget.data;

    values.add(data['program_name']);
    values.add(data['milestone_qty']);
    values.add(data['bonus']);
    values.add(data['redeem_status']);
    values.add(data['achievement']);
    values.add(data['percentage']);
    values.add(data['timeline']);
    values.add(data['start_date']+' - '+data['end_date']);
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Detail Report', center: true),

      body: SingleChildScrollView(
        child: Column(
          children: List.generate(labels.length, (i){
            return Container(
              padding: EdgeInsets.all(15),
              width: Mquery.width(context),
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(labels[i], bold: true),
                  text(values.length <= i ? '-' : values[i])
                ]
              ),
            );
          })
        ),
      ),
    );
  }
}