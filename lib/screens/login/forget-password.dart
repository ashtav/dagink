import 'package:dagink/services/v2/helper.dart';
import 'package:dagink/services/v3/helper.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  var email = TextEditingController();

  var emailNode = FocusNode();

  bool isSubmit = false;

  sendMeEmail(){
    if(email.text.isEmpty){
      Wh.toast('Inputkan email');
      return;
    }


    setState(() {
      isSubmit = true;
    });

    Http.post('forgot_password', debug: true, data: {'email': email.text}, authorization: false, then: (_, data){
      Navigator.pop(context, {'success': true});
    }, error: (err){
      onError(context, response: err);
      setState(() => isSubmit = false );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: Wh.appBar(context, title: 'Lupa Password', elevation: 0, center: true),

        body: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[

              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[

                        Container(
                          height: 100, width: 100, margin: EdgeInsets.only(bottom: 35),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/img/lock.png')
                            )
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              text('Inputkan email yang telah Anda daftarkan.', bold: true, size: 17),
                              text('Kami akan mengirimkan link untuk reset ulang password Anda', color: Colors.black45),

                            ],
                          )
                          
                        ),

                        Fc.textfield(
                          controller: email, hint: 'Inputkan alamat email',
                          length: 50, suffix: Icon(Ic.mail(), size: 18), node: emailNode,
                          type: TextInputType.emailAddress
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              Button(
                onTap: (){
                  sendMeEmail();
                },
                isSubmit: isSubmit,
                text: 'Reset Password',
              )

            ],
          ),
        ),
      ),
    );
  }
}