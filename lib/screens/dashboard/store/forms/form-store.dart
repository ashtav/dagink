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
      regencyId = new TextEditingController(),
      districtId = new TextEditingController(),
      urbanVillageId = new TextEditingController(),
      zipCode = new TextEditingController(),
      address = new TextEditingController();

  var regency = TextEditingController(),
      district = TextEditingController(),
      urban = TextEditingController();

  FocusNode nameNode = FocusNode(), 
            ownerNode = FocusNode(), 
            phoneNode = FocusNode();

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
      'regency_id': regencyId.text,
      'district_id': districtId.text,
      'urban_village_id': urbanVillageId.text,
      'zip_code': zipCode.text,
      'address': address.text
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

      Http.put('store/'+widget.initData['id'].toString(), data: formData, then: (_, data){
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
      print(data);
      // set input
      name.text = data['name'];
      owner.text = data['owner'];
      phone.text = data['phone'];
      address.text = data['address'];
      zipCode.text = data['zip_code'];

      String regId = data['regency']['id'].toString();

      regencyId.text = regId;
      regency.text = data['regency']['name'];

      String disId = data['district']['id'].toString();

      getDistrict(regId);
      districtId.text = data['district']['id'].toString();
      district.text = data['district']['name'];

      String urbId = data['urban_village']['id'].toString();

      getUrban(disId);
      urbanVillageId.text = urbId;
      urban.text = data['urban_village']['name'];
    }
  }

  autoLocation({bool init: true}) async{
    var locationEnabled = await Gps.enabled();
                              
    if(init) if(locationEnabled){
      var location = await Gps.location();
      address.text = location.thoroughfare+', '+location.subLocality+', '+location.locality+' '+location.subAdministrativeArea+', '+location.administrativeArea;
      zipCode.text = location.postalCode;
    }else{
      Wh.toast('Aktifkan gps Anda');
    }
  }

  @override
  void initState() {
    super.initState();
    getRegency(); autoLocation(init: widget.initData == null);
  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        appBar: Wh.appBar(context, title: widget.initData == null ? 'Tambah Toko' : 'Edit Toko', center: true, actions: [
          IconButton(
            icon: request ? Wh.spiner() : Icon(Ln.refresh()),
            onPressed: request ? null : (){
              getRegency();
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
                          label: 'Nomor Telepon', hint: 'Nomor telepon', controller: phone, type: TextInputType.datetime, length: 15, node: phoneNode,
                        ),

                        SelectCupertino(
                          label: 'Kabupaten', controller: regency,
                          hint: 'Pilih kabupaten', enabled: regencies.length > 0,
                          options: regencies.map((i) => i['name']).toList(),
                          values: regencies.map((i) => i['id']).toList(),
                          select: (res){
                            regencyId.text = res['value'];
                            getDistrict(res['value']);
                          },
                        ),

                        SelectCupertino(
                          label: 'Kecamatan', controller: district,
                          hint: 'Pilih kecamatan', enabled: districts.length > 0,
                          options: districts.map((i) => i['name']).toList(),
                          values: districts.map((i) => i['id']).toList(),
                          select: (res){
                            districtId.text = res['value'];
                            getUrban(res['value']);
                          },
                        ),

                        SelectCupertino(
                          label: 'Kelurahan', controller: urban,
                          hint: 'Pilih kelurahan', enabled: urbans.length > 0,
                          options: urbans.map((i) => i['name']).toList(),
                          values: urbans.map((i) => i['id']).toList(),
                          select: (res){
                            urbanVillageId.text = res['value'];
                          },
                        ),

                        TextInput(
                          label: 'Alamat', hint: 'Inputkan alamat', controller: address, suffix: WidSplash(
                            child: Icon(Ln.mapMarked()),
                            onTap: () async {
                              autoLocation();
                            },
                          ),
                        ),

                        TextInput(
                          label: 'Kode Pos', hint: 'Kode pos', controller: zipCode, type: TextInputType.datetime, length: 5,
                        ),



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