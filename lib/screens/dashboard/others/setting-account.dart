import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class SettingAccount extends StatefulWidget {
  @override
  _SettingAccountState createState() => _SettingAccountState();
}

class _SettingAccountState extends State<SettingAccount> {

  var email = TextEditingController(),
      password = TextEditingController(),
      passConf = TextEditingController();

  bool isSubmit = false;

  initAccount() async{
    var auth = await Auth.user();

    setState(() {
      email.text = auth['email'];
    });
  }

  submit() async{
    if(password.text.length < 8){
      Wh.toast('Minimal password 8 karakter'); return;
    }

    if(password.text != passConf.text){
      Wh.toast('Konfirmasi password tidak sama'); return;
    }

    setState(() {
      isSubmit = true;
    });
  }

  @override
  void initState() {
    super.initState(); initAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Pengaturan Akun', center: true),

      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [

                  TextInput(
                    label: 'Email', hint: 'Inputkan email',
                    controller: email,
                  ),

                  TextInput(
                    label: 'Password', hint: 'Inputkan password',
                    controller: password, obsecure: true,
                  ),

                  TextInput(
                    label: 'Konfirmasi Password', hint: 'Inputkan konfirmasi password',
                    controller: passConf, obsecure: true,
                  )

                ]
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(15),
            child: Button(
              onTap: (){ submit(); },
              text: 'Simpan', isSubmit: isSubmit,
            ),
          )

        ]
      )
    );
  }
}