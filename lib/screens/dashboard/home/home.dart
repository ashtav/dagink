import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home(this.ctx);

  final ctx;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.silver(),
      appBar: Wh.appBar(context, title: 'Home', center: true, back: false),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // Container(
            //   padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            //   child: Container(
            //     padding: EdgeInsets.all(10), width: Mquery.width(context),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(3),
            //       color: Color.fromRGBO(237, 242, 250, 1),
            //       border: Border.all(color: Color.fromRGBO(70, 127, 207, 1))
            //     ),
            //     child: text('Selamat datang di Dagink'),
            //   ),
            // ),

            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: List.generate(2, (i) {
                      List heights = [180.0, 130.0],
                            labels = ['Point','Pemmbelian'],
                            values = [34, 2];

                      return Container(
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.all(2),
                        height: heights[i],
                        width: Mquery.width(context) / 2 - 19,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12)
                        ),
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
                        )
                        
                      );
                    })
                  ),

                  Column(
                    children: List.generate(2, (i) {
                      List heights = [140.0, 230.0];

                      return Container(
                        padding: EdgeInsets.all(15), margin: EdgeInsets.all(2),
                        height: heights[i],
                        width: Mquery.width(context) / 2 - 19,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12)
                        ),
                        child: text('text'),
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