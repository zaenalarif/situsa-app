import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main()
{
  runApp(MaterialApp(
    home: Login(),
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String username, password;
  final _key = new GlobalKey<FormState>();
  check(){
    final form = _key.currentState;
    if(form.validate()){
      form.save();
      login();
    }
  }

  login() async {
   http.post("http://192.168.43.177:8000/api/login", 
   headers: {
     "Accept": "application/json",
   },
   body: {
     "no_thl"   : username,
     "password" : password
   }).then((res){
     print(res.body);
     
   }).catchError((onError){
     print(onError);
     
   }); 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
          child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              validator: (e){
                if(e.isEmpty){
                  return "isi kolomnya";
                }
              },
              onSaved: (e)=> username = e,
              decoration: InputDecoration(
                labelText: "Username"
              )
            ),
            TextFormField(
              obscureText: true,
              onSaved: (e)=> password = e,
              decoration: InputDecoration(
                labelText: "password"
              )
            ),
            MaterialButton(
              onPressed: (){
                check();
              },
              child: Text("Login")
              ),
        ],
      ),
      ),
    );
  }
}