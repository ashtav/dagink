import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Achievement extends StatefulWidget {
  Achievement(this.ctx);

  final ctx;

  @override
  _BalanceHistoriesState createState() => _BalanceHistoriesState();
}

class _BalanceHistoriesState extends State<Achievement> {

  bool loading = true;
  List achivements = [];

  getData() async{

    setState(() {
      loading = true;
    });

    Http.get('user/program/achievement', then: (_, data){
      Map res = decode(data);
      
      achivements = res['data'];

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
      appBar: Wh.appBar(context, title: 'Achievement', center: true),

      body: loading ? ListSkeleton(length: 15) : 

      RefreshIndicator(
        onRefresh: () async { getData(); },
        child: ListView.builder(
          itemCount: achivements.length,
          itemBuilder: (BuildContext context, i){
            var data = achivements[i];

            return WidSplash(
              onTap: (){
                Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => DetailAchievement(widget.ctx, data: data)));
              },
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text(data['program_name'], bold: true),
                          text(data['start_date']+' - '+data['end_date'], size: 13)
                        ]
                      ),

                      text(data['percentage'].toString()+'%')

                    ],
                  )
                  

                  
                ],
              ),
            );
          }
        ),
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
      appBar: Wh.appBar(context, title: 'Detail Achievement', center: true),

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