import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class SearchStore extends StatefulWidget {
  @override
  _SearchStoreState createState() => _SearchStoreState();
}

class _SearchStoreState extends State<SearchStore> {

  var keyword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SlideDown(
      child: Column(
        children: [

          Material(
            color: Colors.transparent,
            child: Container(
              width: Mquery.width(context),
              margin: EdgeInsets.only(left: 10, right: 10, top: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3)
              ),
              child: Column(
                children: [
                  Fc.search(
                    controller: keyword, hint: 'Ketik nama toko', autofocus: true,
                    length: 50, prefix: Icon(Ln.search(), size: 18), submit: (String s){ Navigator.pop(context, s); },
                    action: TextInputAction.go,
                  ),
                ]
              ),
            ),
          ),

        ]
      )
      
      
    );
  }
}