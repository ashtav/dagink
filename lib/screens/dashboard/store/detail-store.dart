import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class DetailStore extends StatefulWidget {
  DetailStore({this.data});

  final data;

  @override
  _DetailStoreState createState() => _DetailStoreState();
}

class _DetailStoreState extends State<DetailStore> {

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: ucwords(widget.data['name']), center: true, actions: [
        IconButton(
          icon: Icon(Ln.mapMarked()),
          onPressed: (){
            openMap(double.parse(widget.data['latitude']), double.parse(widget.data['longitude']));
          },
        )
      ]),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (i){
            var data = widget.data;

            List  labels = ['nama toko','nama pemilik','alamat','kode pos'],
                  values = [
                    ucwords(data['name']), ucwords(data['owner']), data['address'], data['zip_code']
                  ];


            return Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: i % 2 == 0 ? TColor.silver() : Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(ucwords(labels[i]), bold: true),
                  text(values[i]),
                ],
              ),
            );

          }),
        ),
      ),
    );
  }
}