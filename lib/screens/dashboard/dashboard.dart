import 'dart:async';

import 'package:dagink/screens/dashboard/home/home.dart';
import 'package:dagink/screens/dashboard/others/others.dart';
import 'package:dagink/screens/dashboard/purchase/purchase.dart';
import 'package:dagink/screens/dashboard/sales/sales.dart';
import 'package:dagink/screens/dashboard/store/store.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Dashboard extends StatefulWidget {
  Dashboard({this.tabIndex: 0}); final tabIndex;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  
  TabController controller;
  DateTime currentBackPressTime;

  var index = 0, pageIndex = 0, isLogged = false, roles;
  bool isPageReady = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    Timer(Duration(milliseconds: 300), (){
      statusBar(color: Colors.transparent, darkText: true);
    });

    controller = new TabController(vsync: this, length: 5);
    controller.index = widget.tabIndex;
    index = pageIndex = widget.tabIndex;

    getPrefs('roles', type: List).then((res) async{
      statusBar(color: Colors.transparent, darkText: false);
      roles = res;

      Timer(Duration(seconds: 1), (){
        setState(() {
          isPageReady = true;
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      statusBar(color: Colors.transparent, darkText: true);
    }
  }

  isSales(){
    if( roles.indexOf('salesman') > -1 || roles.indexOf('salesman canvass') > -1 ){
      return true;
    }

    return false;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)){
      currentBackPressTime = now;
      Wh.toast('Tekan sekali lagi untuk keluar');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: onWillPop, // prevent click back on device
      child: new Scaffold(
        backgroundColor: Color.fromRGBO(229, 232, 236, 1),
        body: !isPageReady ? Wh.spiner(size: 50) : 
        
        ZoomIn(
          child: Stack(
            children: List<Widget>.generate(5, (int index) {
              return IgnorePointer(
                ignoring: index != pageIndex,
                child: Opacity(
                  opacity: pageIndex == index ? 1 : 0,
                  child: Navigator(
                    onGenerateRoute: (RouteSettings settings) {
                      return new MaterialPageRoute(
                        builder: (_){
                          switch (index) {
                            case 0: return Home(context); break;
                            case 1: return Store(context); break;
                            case 2: return Sales(context); break;
                            case 3: return Purchase(context); break;
                            default: return Others(context); break;
                          }
                        },
                        settings: settings,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
        
        bottomNavigationBar: isPageReady ? _bottomNavigationBar() : SizedBox.shrink()
      )
    );
  }

  initTabs(){
    List<Widget> list = [];
    var labels = ['Home','Toko','Penjualan','Pembelian','Lainnya'],
        icons = [Ln.home(),Ln.store(),Ln.shopping(),Ln.clipboardlist(),Entypo.list];

    for (var i = 0; i < labels.length; i++) {
      var _color = i == pageIndex ? TColor.azure() : Colors.grey;

      list.add(
        Tab(child: Container(
          margin: EdgeInsets.only(top: 5),
          child: Column(
            children: <Widget>[
              Icon(icons[i], color: _color, size: 21),
              text(labels[i], color: _color, size: 12)
            ]),
          ),
        ),
      );
    }

    return list;
  }

  _bottomNavigationBar(){
    return SlideUp(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromRGBO(0, 0, 0, .05))
          )
        ),
        child: new Material(
          color: Colors.white,
          child: new TabBar(
            onTap: (int i) async{
              setState(() { pageIndex = i; });
              statusBar(color: Colors.transparent, darkText: true);

              // switch (i) {
              //   case 0: statusBar(color: Colors.transparent, darkText: false); break;
              //   default: statusBar(color: Colors.transparent, darkText: true); break;
              // }

            },
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontSize: 11),
            labelPadding: EdgeInsets.all(0),
            controller: controller,
            tabs: initTabs(),
          )
        ),
      ),
    );
  }

}