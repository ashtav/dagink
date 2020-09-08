import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormProfil extends StatefulWidget {
  @override
  _FormProfilState createState() => _FormProfilState();
}

class _FormProfilState extends State<FormProfil> {

  var name = TextEditingController(),
      email = TextEditingController(),
      address = TextEditingController(),
      phone = TextEditingController(),
      noKendaraan = TextEditingController();

  var passNode = FocusNode();

  bool isSubmit = false;

  initData() async{
    var auth = await Auth.user(); print(auth);

    setState(() {
      name.text = auth['name'];
      email.text = auth['email'];
      address.text = auth['address'];
      phone.text = auth['phone'];
      noKendaraan.text = auth['vehicle'];
    });
  }

  submit() async{
    setState(() {
      isSubmit = true;
    });

    String uid = await Auth.id();
    var auth = await Auth.user();

    var formData = {
      'name': name.text,
      'email': email.text,
      'address': address.text,
      'phone': phone.text,
      'gender': auth['gender'],
      'role': auth['role'],
      'code': auth['code'],
      'driving_license_number': auth['driving_license_number'],
      'identity_card': auth['identity_card'],
      'vehicle': noKendaraan.text
    };

    Http.post('user/'+uid, debug: true, data: formData, then: (_, data){

      auth['name'] = name.text;
      auth['email'] = email.text;
      auth['address'] = address.text;
      auth['phone'] = phone.text;
      auth['vehicle'] = noKendaraan.text;

      setPrefs('user', auth, enc: true);

      Navigator.pop(context, {'success': true});
    }, error: (err){
      setState(() => isSubmit = false );
      onError(context, response: err, popup: true);
    });
  }

  @override
  void initState() {
    super.initState(); initData();
  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: 'Pengaturan Profil', center: true),

        body: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [

                    TextInput(
                      label: 'Nama', hint: 'Inputkan nama',
                      controller: name,
                    ),

                    TextInput(
                      label: 'Email', hint: 'Inputkan email',
                      controller: email,
                    ),

                    TextInput(
                      label: 'No. Telepon', hint: 'Inputkan no. telepon',
                      controller: phone,
                    ),

                    TextInput(
                      label: 'Alamat Lengkap', hint: 'Inputkan alamat lengkap',
                      controller: address,
                    ),

                    TextInput(
                      label: 'No. Kendaraan', hint: 'Inputkan no. kendaraan',
                      controller: noKendaraan,
                    ),

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
      ),
    );
  }
}