import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class FormStore extends StatefulWidget {
  FormStore({this.initData});

  final initData;

  @override
  _FormStoreState createState() => _FormStoreState();
}

class _FormStoreState extends State<FormStore> {

  var name = new TextEditingController(),
      owner = new TextEditingController(),
      phone = new TextEditingController(),
      remark = new TextEditingController(),
      zipCode = new TextEditingController(),
      address = new TextEditingController();

  var regency = TextEditingController(),
      district = TextEditingController(),
      urban = TextEditingController();

  FocusNode nameNode = FocusNode(), 
            ownerNode = FocusNode(), 
            phoneNode = FocusNode(),
            keteranganNode = FocusNode();

  var regencies = [], districts = [], urbans = [];

  bool request = false, isSubmit = false;

  getRegency(){
    setState(() {
      request = true;
    });

    Http.get('location/regency', then: (_, data){
      setState((){
        request = false;

        regency.clear();
        district.clear();
        urban.clear();

        regencies = districts = urbans = [];

        initForm();
      });

      var res = decode(data)['data'];
      regencies = res;
    }, error: (err){
      setState(() => request = false );
      onError(context, response: err, popup: true);
    });
  }

  getDistrict(String id){
    setState((){
      request = true;

      district.clear();
      urban.clear();

      districts = urbans = [];
    });

    Http.get('location/district/'+id, then: (_, data){
      var res = decode(data)['data'];
      districts = res;
      setState(() => request = false );
    }, error: (err){
      setState(() => request = false );
      onError(context, response: err, popup: true);
    });
  }

  getUrban(String id){
    setState((){
      request = true;
      urban.clear();
      urbans = [];
    });

    Http.get('location/urban_village/'+id, then: (_, data){
      var res = decode(data)['data'];
      urbans = res;
      setState(() => request = false );
    }, error: (err){
      setState(() => request = false );
      onError(context, response: err, popup: true);
    });
  }

  submit() async{
    var locationEnabled = await Gps.enabled();
    if(!locationEnabled){
      Wh.toast('Aktifkan gps');
      return;
    }

    if(name.text.isEmpty || owner.text.isEmpty || phone.text.isEmpty){
      Wh.toast('Lengkapi form'); return;
    }

    await autoLocation(init: true);

    setState(() {
      isSubmit = true;
    });

    var gps = await Gps.latlon();

    Map formData = {
      'name': name.text,
      'owner': owner.text,
      'phone': phone.text,
      'latitude': gps.latitude.toString(),
      'longitude': gps.longitude.toString(),
      'regency': regency.text,
      'district': district.text,
      'urban_village': urban.text,
      'zip_code': zipCode.text,
      'address': address.text,
      'remark': remark.text
    };

    if(widget.initData == null){
      Http.post('store', data: formData, then: (_, data){
        Wh.toast('Berhasil ditambahkan');
        Navigator.pop(context, {'added': true});
      }, error: (err){
        setState(() => isSubmit = false );
        onError(context, response: err, popup: true);
      });
    }else{
      formData['code'] = widget.initData['code'];

      Http.put('store/'+widget.initData['id'].toString(), debug: true, data: formData, then: (_, data){
        Wh.toast('Berhasil diperbarui');
        Navigator.pop(context, {'updated': true, 'data': formData});
      }, error: (err){
        setState(() => isSubmit = false );
        onError(context, response: err, popup: true);
      });
    }
  }

  initForm(){
    var data = widget.initData;
    if(data != null){
      
      name.text = data['name'];
      owner.text = data['owner'];
      phone.text = data['phone'];
      address.text = data['address'];
      zipCode.text = data['zip_code'];
      remark.text = data['remark'];

      regency.text = data['regency'];
      district.text = data['district'];
      urban.text = data['urban_village'];
    }
  }

  autoLocation({bool init: true}) async{
    var locationEnabled = await Gps.enabled();
                              
    if(init) if(locationEnabled){
      requestPermissions(location: true, then: (allowed) async{
        if(allowed){

          var location = await Gps.location();

          setState(() {

            address.text = location.thoroughfare+', '+location.subLocality+', '+location.locality+' '+location.subAdministrativeArea+', '+location.administrativeArea+', '+location.postalCode;
            zipCode.text = location.postalCode;

            regency.text = location.subAdministrativeArea;
            district.text = location.locality;
            urban.text = location.subLocality;

          });
        }else{
          Wh.toast('Gps tidak tersedia');
        }
      });

    }else{
      Wh.toast('Aktifkan gps Anda');
    }
  }

  @override
  void initState() {
    super.initState();
    autoLocation(); initForm();
  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: widget.initData == null ? 'Tambah Toko' : 'Edit Toko', center: true, actions: [
          IconButton(
            icon: request ? Wh.spiner() : Icon(Ln.mapMarked()),
            onPressed: request ? null : (){
              autoLocation();
            },
          )
        ]),

        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PreventScrollGlow(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[

                        TextInput(
                          label: 'Nama Toko', hint: 'Nama toko', controller: name, node: nameNode, action: TextInputAction.next, submit: (String _){ focus(context, ownerNode); },
                        ),

                        TextInput(
                          label: 'Nama Pemilik', hint: 'Nama pemilik', controller: owner, node: ownerNode, action: TextInputAction.next, submit: (String _){ focus(context, phoneNode); },
                        ),

                        TextInput(
                          label: 'Nomor Telepon', hint: 'Nomor telepon', controller: phone, type: TextInputType.datetime, length: 15, node: phoneNode, action: TextInputAction.next, submit: (String _){ focus(context, keteranganNode); },
                        ),

                        TextInput(
                          label: 'Keterangan', hint: 'Keterangan', controller: remark, maxLines: 3, node: keteranganNode,
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Icon(Ln.mapMarked()),
                              ),

                              Flexible(
                                child: text(address.text, bold: true)
                              )
                            ],
                          ),
                        ),

                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Icon(Ln.infoCircle()),
                              ),

                              Flexible(
                                child: text('Lokasi seperti kabupaten, kecamatan, kelurahan dan lainnya diset secara otomatis berdasarkan tempat dimana Anda berada.')
                              )
                            ],
                          ),
                        ),

                        // TextInput(label: 'Kabupaten', controller: regency, enabled: false),
                        // TextInput(label: 'Kecamatan', controller: district, enabled: false),
                        // TextInput(label: 'Kelurahan', controller: urban, enabled: false),
                        // TextInput(label: 'Alamat', controller: address, enabled: false),
                        // TextInput(label: 'Kode Pos', enabled: false, controller: zipCode),

                      ],
                    ),
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.all(15),
                child: Button(
                  onTap: isSubmit || request ? null : (){ submit(); },
                  text: 'Simpan Toko', isSubmit: isSubmit,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}