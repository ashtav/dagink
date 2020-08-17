import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class BalanceHistories extends StatefulWidget {
  BalanceHistories(this.ctx);

  final ctx;

  @override
  _BalanceHistoriesState createState() => _BalanceHistoriesState();
}

class _BalanceHistoriesState extends State<BalanceHistories> {

  bool loading = true;
  List balances = [];

  getData() async{
    String uid = await Auth.id();

    Http.get('user/'+uid+'/balance', then: (_, data){
      Map res = decode(data);
      balances = res['data'][0]['balance_histories'];
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
      appBar: Wh.appBar(context, title: 'Riwayat Saldo', center: true),

      body: loading ? ListSkeleton(length: 15) : 

      RefreshIndicator(
        onRefresh: () async { getData(); },
        child: ListView.builder(
          itemCount: balances.length,
          itemBuilder: (BuildContext context, i){
            var data = balances[i];

            return WidSplash(
              color: i % 2 == 0 ? TColor.silver() : Colors.white,
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(data['transaction_date']),
                  text('Saldo Masuk : '+nformat(data['in'])+', Saldo Keluar : '+nformat(data['out'])),
                  text(data['note'])
                ],
              ),
            );
          }
        ),
      )
    );
  }
}