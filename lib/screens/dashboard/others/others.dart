import 'package:dagink/screens/dashboard/others/balance-histories.dart';
import 'package:dagink/screens/dashboard/others/profile.dart';
import 'package:dagink/screens/dashboard/others/setting-account.dart';
import 'package:dagink/screens/login/login.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Others extends StatefulWidget {
  Others(this.ctx);

  final ctx;

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {

  Map user = {};
  bool loading = false;

  initAuth() async{
    var auth = await Auth.user();
    user = auth;

    print(auth);
  }

  @override
  void initState() {
    super.initState(); initAuth();
  }

  logout(){
    showDialog(
      context: widget.ctx,
      child: OnProgress()
    );

    Http.get('logout', then: (_, data){
      clearPrefs(except: ['user','order']);

      Navigator.of(widget.ctx).popUntil((route) => route.isFirst);
      Navigator.of(widget.ctx).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Login()));

    }, error: (err){
      onError(context, response: err);
      Navigator.pop(context);
    });
  }

  getProfile() async{
    setState(() => loading = true );

    var auth = await Auth.user();
    print(auth.runtimeType);

    Http.get('me', then: (_, data) async{
      setState(() => loading = false );

      setPrefs('user', data);

      setState(() {
        loading = false;
        user = decode(data);
      });
    }, error: (err){
      setState(() => loading = false );
      onError(context, response: err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.silver(),
      appBar: Wh.appBar(context, title: 'Akun Saya', elevation: 0, back: false, center: true),

      body: RefreshIndicator(
        onRefresh: () async {
          getProfile();
        },
        child: ListView(
            children: [

              Container(
                // padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black12)),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 60, width: 60, margin: EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: AssetImage('assets/img/profile.png')
                              )
                            ),
                            // child: FadeInImage.assetNetwork(
                            //   height: 50, width: 50,
                            //   placeholder: 'assets/img/no-img.png',
                            //   image: apii+'images/items/'+data['gambar'],
                            // ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text(user['name'], bold: true),
                              text('Mitra Motoris')
                            ]
                          )

                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: WidSplash(
                        onTap: (){
                          Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => BalanceHistories(widget.ctx)));
                        },
                        color: TColor.azure(),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[

                                  loading ? Wh.spiner(color: Colors.white, size: 20) : Icon(Ln.wallet(), size: 20, color: Colors.white,),

                                  Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: text('Jumlah Saldo', color: Colors.white)
                                  )

                                ],
                              ),

                              text('Rp '+Cur.rupiah(user['balance']), color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(2, (i){
                          List  labels = ['Data Profil','Pengaturan Akun'],
                                icons = [Ln.user(),Ln.userSetting()];

                          return WidSplash(
                            onTap: (){
                              switch (i) {
                                case 0:
                                  Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => Profile(widget.ctx)));
                                  
                                  break;
                                default:
                                  Navigator.push(widget.ctx, MaterialPageRoute(builder: (context) => SettingAccount())).then((value){
                                    if(value != null){
                                      Wh.toast('Password berhasil diperbarui');
                                    }
                                  });
                              }
                            },
                            color: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              width: Mquery.width(context),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(icons[i])
                                  ),

                                  text(labels[i]),
                                ],
                              )
                            ),
                          );
                        })
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(3, (i){
                          List  labels = ['Komunitas','Bantuan','Nilai Kami'],
                                icons = [Ln.users(),Ln.infoCircle(),Ln.star()];

                          return WidSplash(
                            onTap: (){

                            },
                            color: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              width: Mquery.width(context),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(icons[i])
                                  ),

                                  text(labels[i]),
                                ],
                              )
                            ),
                          );
                        })
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(1, (i){
                          List labels = ['Logout'],
                                icons = [Ln.signout()];

                          return WidSplash(
                            onTap: (){
                              Wh.confirmation(widget.ctx, message: 'Yakin ingin keluar dari akun ini?', confirmText: 'Keluar Sekarang', then: (res){
                                if(res == 0){
                                  logout();
                                }
                              });
                            },
                            color: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              width: Mquery.width(context),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: Icon(icons[i], color: Colors.red)
                                  ),

                                  text(labels[i], color: Colors.red),
                                ],
                              )
                            ),
                          );
                        })
                      ),
                    )

                  ]
                ),
              )

            ]
          ),
      ),
    );
  }
}