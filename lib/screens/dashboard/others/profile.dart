import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  Profile(this.ctx);

  final ctx;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  var user = {};
  List labels = ['Nik','Nama Lengkap','Jenis Kelamin','Alamat','No. Telepon','Email','Surat Izin Mengemudi'],
      values = [];

  initProfile() async{
    var auth = await LocalData.get('user');

    setState(() {
      user = decode(auth) ?? {};

      List keys = ['identity_card','name','gender','address','phone','email','driving_license_number'];

      for (var i = 0; i < labels.length; i++) {
        values.add(user[keys[i].toString()]);
      }
    });
  }

  @override
  void initState() {
    super.initState(); initProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Data Profil', center: true),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(labels.length, (i){
                  return Container(
                    width: Mquery.width(context),
                    padding: EdgeInsets.all(15),
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

            Container(
              padding: EdgeInsets.all(15),
              child: Button(
                onTap: (){ },
                text: 'Perbarui Data Profil',
              ),
            )
            
          ],
        ),
      )
    );
  }
}