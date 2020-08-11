import 'package:dagink/screens/dashboard/store/detail-store.dart';
import 'package:dagink/screens/dashboard/store/forms/form-store.dart';
import 'package:dagink/screens/dashboard/store/forms/search-store.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Store extends StatefulWidget {
  Store(this.ctx);

  final ctx;

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {

  bool loading = false;
  var keyword = TextEditingController();

  List stores = [], filter = [];

  getData() async{
    setState(() {
      loading = true;
      keyword.clear();
    });

    String uid = await Auth.id();

    Http.get('store?created_by='+uid, then: (_, data){
      Map res = decode(data);
      stores = filter = res['data'];

      setState(() => loading = false );
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err, popup: true);
    });
  }

  deleteStore(String id){
    showDialog(context: widget.ctx, child: OnProgress()).then((value) => getData()); // progress indicator

    Http.delete('store/'+id, debug: true, then: (_, data){
      Wh.toast('Berhasil dihapus');
      Navigator.pop(widget.ctx);
    }, error: (err){
      onError(context, response: err, popup: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Wh.appBar(context, title: 'Toko', center: true, back: false, actions: [
        // IconButton(
        //   icon: loading ? Wh.spiner() : Icon(Ln.refresh()),
        //   onPressed: loading ? null : (){
        //     getData();
        //   },
        // ),

        IconButton(
          icon: Icon(Ln.search()),
          onPressed: loading ? null : (){
            showDialog(
              context: context,
              child: SearchStore()
            ).then((value){
              if(value != null){
                String k = value.toString().toLowerCase();
                keyword.text = k;

                setState(() {
                  filter = stores.where((item) => item['name'].toString().toLowerCase().contains(k)).toList();
                });
              }
            });
          },
        )
      ]),

      body: loading ? ListSkeleton(length: 15) : filter.length == 0 ? 
      
        RefreshIndicator( onRefresh: () async{  getData();  },
          child: Center(
            child: PreventScrollGlow(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Wh.noData(message: 'Tidak ada data toko\nTap + untuk menambahkan')
                ],
              ),
            ),
          )
        ) :

        RefreshIndicator(
          onRefresh: () async{  getData();  },
          child: Column(
            children: [
              
              keyword.text.isNotEmpty ?
              WidSplash(
                onTap: (){
                  setState(() {
                    keyword.clear();
                    filter = stores;
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: TColor.gray()
                  ),
                  child: html('Hasil pencarian <b>'+keyword.text+'</b> ('+filter.length.toString()+' toko)', color: Colors.white),
                ),
              ) : SizedBox.fromSize(),

              Expanded(
                child:  ListView.builder(
                  itemCount: filter.length,
                  itemBuilder: (BuildContext context, i){
                    var data = filter[i];

                    return WidSplash(
                      padding: EdgeInsets.all(15),
                      color: i % 2 == 0 ? TColor.silver() : Colors.white,
                      onTap: (){
                        Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => DetailStore(data: data)));
                      },

                      onLongPress: (){
                        Wh.options(widget.ctx, options: ['Edit Toko','Hapus Toko'], icons: [Ln.edit(), Ln.trash()], danger: [1], then: (res){
                          Navigator.pop(widget.ctx);
                          
                          switch (res) {
                            case 0:
                              Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormStore(initData: data))).then((value){
                                if(value != null){
                                  getData();
                                }
                              });

                              
                              break;
                            default:
                              Wh.confirmation(widget.ctx, message: 'Yakin ingin menghapus data toko ini?', confirmText: 'Hapus Toko', then: (res){
                                if(res == 0){
                                  Navigator.pop(widget.ctx);
                                  deleteStore(data['id'].toString());
                                }
                              });
                          }
                        });
                      },

                      child: Container(
                        child: Row(
                          children: <Widget>[
                            // Container(
                            //   margin: EdgeInsets.only(right: 10),
                            //   padding: EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black12),
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(3)
                            //   ),
                            //   child: Icon(Ln.store(), size: 25,),
                            // ),

                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(ucwords(data['name']), bold: true),
                                  text(ucwords(data['address']))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ]
          ),
        ),
      
       
      floatingActionButton: FloatingActionButton(
        heroTag: 'store',
        child: Icon(Ln.plus()),
        onPressed: (){
          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => FormStore())).then((value){
            if(value != null){
              getData();
            }
          });
        },
      ),
    );
  }
}