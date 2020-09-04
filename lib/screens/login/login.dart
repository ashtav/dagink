import 'package:dagink/screens/dashboard/dashboard.dart';
import 'package:dagink/screens/login/forget-password.dart';
import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var email = TextEditingController(text: 'hehe@gmail.com'),
      password = TextEditingController(text: '123qweqwe');

  var emailNode = FocusNode(),
      passNode = FocusNode();

  bool obsecure = true, isSubmit = false;

  signin(){
    requestPermissions(location: true, then: (allowed){
      if(allowed){
        if(email.text.isEmpty || password.text.isEmpty){
          focus(context, email.text.isEmpty ? emailNode : passNode);
        }else{
          setState(() => isSubmit = true );

          Http.post('login', data: {'email': email.text, 'password': password.text}, authorization: false, then: (_, data){
            setState(() => isSubmit = false );

            var res = decode(data),
                user = res['data'],
                token = 'Bearer '+res['token_data']['access_token'];

            setPrefs('user', user, enc: true);
            setPrefs('token', token, enc: true);

            Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));

          }, error: (err){
            onError(context, response: err);
            setState(() => isSubmit = false );
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    requestPermissions(location: true);
  }

  @override
  Widget build(BuildContext context) {
    statusBar(color: Colors.transparent, darkText: true);

    return Unfocus(
      child: Scaffold(
        backgroundColor: TColor.silver(),
        body: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        Container(
                          width: 150,
                          height: 150, margin: EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/logo.png'),
                              fit: BoxFit.cover
                            )
                          ),
                        ),

                        Fc.textfield(
                          controller: email, hint: 'Inputkan alamat email',
                          length: 50, suffix: Icon(Ic.mail(), size: 18), node: emailNode, submit: (String s){ focus(context, passNode); },
                          type: TextInputType.emailAddress, action: TextInputAction.next,
                        ),

                        Fc.textfield(
                          controller: password, hint: 'Inputkan password', obsecure: obsecure,
                          length: 15, node: passNode, submit: (String s){ signin(); }, marginBottom: 0,
                          type: TextInputType.emailAddress, action: TextInputAction.go,
                          suffix: WidSplash(
                            onTap: (){
                              setState(() => obsecure = !obsecure );
                            },
                            child: Icon(obsecure ? Ic.lock() : Ic.unlock(), size: 18,),
                          )
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            WidSplash(
                              splash: Colors.transparent, highlightColor: Colors.transparent,
                              padding: EdgeInsets.only(top: 15, bottom: 15),
                              child: text('Saya lupa password', color: TColor.azure(), align: TextAlign.right),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()));
                              },
                            ),

                          ]
                        )

                      ],
                    ),
                  ),
                ),
              ),

              


              Button(
                onTap: isSubmit ? null : (){
                  signin();
                }, isSubmit: isSubmit,
                text: 'Login',
              )

            ],
          ),
        ),
      ),
    );
  }
}