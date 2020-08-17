import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormEditHarga extends StatefulWidget {
  FormEditHarga(this.data);

  final data;

  @override
  _FormEditStockState createState() => _FormEditStockState();
}

class _FormEditStockState extends State<FormEditHarga> {

  var price = TextEditingController();

  bool isSubmit = false;

  initForm(){
    var data = widget.data;
    if(data != null){
      price.text = data['sale_price'].toString();
    }

  }

  submit(){
    if(price.text.isEmpty){
      Wh.toast('Lengkapi harga');
    }else{
      setState(() {
        isSubmit = true;
      });

      Http.put('profuct/'+widget.data['product_id'].toString()+'/sales_price', data: {}, debug: true, header: {'Content-Type': 'application/json'}, then: (_, data){
        setState(() => isSubmit = false );
        Navigator.pop(context, {'added': true});
      }, error: (err){
        setState(() => isSubmit = false );
        onError(context, response: err);
      });


    }
  }

  @override
  void initState() {
    super.initState(); initForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Edit Stock'),

      body: Column(
        children: <Widget>[

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[

                  TextInput(
                    label: 'Harga', controller: price,
                    hint: 'Inputkan harga',
                  )
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(15),
            child: Button( isSubmit: isSubmit,
              onTap: (){ submit(); },
              text: 'Simpan',
            )
          )
        ],
      )
      
      
      
    );
  }
}