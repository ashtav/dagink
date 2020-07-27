import 'package:dagink/services/v2/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ln {
  static home() => LineAwesomeIcons.home;
  static store() => LineAwesomeIcons.store;
  static tags() => LineAwesomeIcons.tags;
  static archive() => LineAwesomeIcons.archive;
  static shopping() => LineAwesomeIcons.shopping_bag;
  static clipboardlist() => LineAwesomeIcons.clipboard_list;
  static plus() => LineAwesomeIcons.plus;
  static refresh() => LineAwesomeIcons.sync_icon;
  static angleLeft() => LineAwesomeIcons.angle_left;
  static mapMarked() => LineAwesomeIcons.map_marked;
  static edit() => LineAwesomeIcons.edit;
  static trash() => LineAwesomeIcons.trash;
  static search() => LineAwesomeIcons.search;
}

class Auth {
  static Future user({String field}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map data = decode(prefs.getString('user'));

    if(field == null){
      return data;
    }else{
      return data[field].toString();
    }
  }

  static Future id() async{
    return await user(field: 'id');
  }
}

class Gps {
  // var data = await Gps.latlon(); -> data.latitude
  static Future latlon() async{ 
    bool location = await Geolocator().isLocationServiceEnabled();

    if(!location){
      return 'Please enabled your location.';
    }

    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    Position position = await geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (position == null) {
      position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }

    return position;
  }

  // bool enabled = await Gps.enabled(); -> if(enabled)
  static Future enabled() async{
    return await Geolocator().isLocationServiceEnabled();
  }

  // var data = await Gps.location(); -> data.thoroughfare;
  static Future location() async {
    var position = await latlon();

    var geolocator = Geolocator();

    try {
      List<Placemark> placemarks = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];

        // pos.thoroughfare+', '+ // alamat
        // pos.subLocality+', '+ // kelurahan
        // pos.locality+', '+ // kecamatan
        // pos.subAdministrativeArea+', '+ // kabupaten
        // pos.administrativeArea+', '+ // provinsi
        // pos.postalCode+', '+ // kode pos
        // pos.country; // negara
        return pos;
      }
    } catch (e) {
      if(e is PlatformException) {
        return e.message;
      }
    }
  }
}

/*  modal(context, height: Mquery.height(context) / 2, 
      child: ListCupertino(options: [], values:[], initValue: controller, onSelect: (res){
        res = {object}
      })
    ); */

class ListCupertino extends StatefulWidget {
  ListCupertino({this.options, this.values, this.initValue, this.onSelect});

  final List options, values;
  final Function onSelect;
  final TextEditingController initValue;

  @override
  _ListCupertinoState createState() => _ListCupertinoState();
}

class _ListCupertinoState extends State<ListCupertino> {

  String selected;
  Map object;

  @override
  void initState() {
    super.initState(); selected = widget.initValue.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70, margin: EdgeInsets.only(bottom: 10),
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(229, 232, 236, 1),
          ),
        ),
        
        Expanded(
          child: PreventScrollGlow(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5)
              ),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: widget.options.indexOf(selected),
                ),
                itemExtent: 40.0,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int i){
                  // if(widget.onSelect != null){
                  //   widget.values != null ? widget.onSelect(widget.values[i]) :  widget.onSelect(widget.options[i]);
                  // }

                  selected = widget.options[i];
                  object = {'option': widget.options[i], 'value': (widget.values == null ? '' : widget.values[i].toString())};
                },
                children: new List<Widget>.generate(
                  widget.options.length, (int index) {
                    return Container(
                      margin: EdgeInsets.all(3),
                      width: Mquery.width(context) - 100,
                      // padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: TColor.silver(),
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: Center(
                        child: text(ucwords(widget.options[index].toString())),
                      ) 
                    );
                  }
                )
              ),
            ),
          ),
        ),

        Container(
          padding: EdgeInsets.all(15),
          color: Colors.white,
          child: Button(
            text: 'Pilih',
            onTap: (){
              setState(() {
                widget.onSelect(object);
                widget.initValue.text = selected;
              });
              Navigator.pop(context);
            }
          )
        )
      ]
    );
  }
}

/*  SelectCupertino(
      label: 'Label', hint: 'hint', controller: controller,
      options: ['A', 'B', 'C', 'D'] or [{}].map((item) => item['property']).toList()
    ), */

class SelectCupertino extends StatefulWidget {
  SelectCupertino({this.label, this.hint, this.select, @required this.controller, this.enabled: true, this.suffix, this.options, this.values});

  final String label, hint;
  final Function select;
  final TextEditingController controller;
  final bool enabled;
  final IconData suffix;
  final List options, values;

  @override
  _SelectCupertinoState createState() => _SelectCupertinoState();
}

class _SelectCupertinoState extends State<SelectCupertino> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          
          widget.label == null ? SizedBox.shrink() :
          Container(
            margin: EdgeInsets.only(bottom: 7),
            child: text(widget.label, bold: true),
          ),

          WidSplash(
            onTap: !widget.enabled ? null : (){
              modal(
                context, height: Mquery.height(context) / 2, 
                child: ListCupertino(options: widget.options, values: widget.values, initValue: widget.controller, onSelect: (res){
                  setState(() {
                    widget.controller.text = res['option'];
                  });

                  if(widget.select != null) widget.select(res);
                })
              );
            },
            color: widget.enabled ? Colors.white : Color.fromRGBO(232, 236, 241, 1),
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              width: Mquery.width(context),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(2)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: text(widget.controller.text.isEmpty ? widget.hint : widget.controller.text, color: widget.controller.text.isEmpty ? Colors.black45 : Colors.black87, overflow: TextOverflow.ellipsis),
                  ),
                  
                  Icon(widget.suffix == null ? Ic.chevron() : widget.suffix, size: 17)
                ],
              )
              
            ),
          )

        ],
      ),
    );
  }
}
