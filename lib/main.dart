import 'dart:convert';

import 'package:api/modal/api.dart';
import 'package:api/view/camera.dart';
import 'package:api/view/presensiSaya.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main()
{
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus{
  notSignIn,
  singIn
}

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
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
   http.post(
    BaseUrl.login, 
    headers: {
      "Accept": "application/json",
    },
    body: {
      "no_thl"   : username,
      "password" : password
    }).then((res){
     
     if(res.statusCode == 200){ 
      final Map<String, dynamic> data = jsonDecode(res.body);
      String name     = data["name"];
      String noThl    = data["no_thl"];
      String token    = data["token"];
      
       setState(() {
         _loginStatus = LoginStatus.singIn;
         savePref(name, noThl, token);
       });
       
     }else{
       setState(() {
         _loginStatus = LoginStatus.notSignIn;
       });
     }
   }).catchError((onError){
     
   }); 
  }

  var name;
  var noThl;
  var token;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name  = preferences.getString("name");
      noThl = preferences.getString("noThl");
      token = preferences.getString("token");
      
      _loginStatus = token != null ? LoginStatus.singIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.clear();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() { 
    super.initState();
    getPref();
  }

  savePref(String _name, String _noThl, String _token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("name", _name);
      preferences.setString("noThl", _noThl);
      preferences.setString("token", _token);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
           return Scaffold(
            appBar: AppBar(title: Text("Situsa"),),
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
        break;
      case LoginStatus.singIn:
        return MainMenu(signOut);
        break;
    }
 
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  MainMenu(this.signOut);
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  TabController tabController;
  
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();


    return DefaultTabController(
      length: 2,
        child: Scaffold(
        appBar: AppBar(
          title: Text("Situsa"),
          actions: <Widget>[
            IconButton(
                onPressed: (){
                  signOut();
                },
                icon: Icon(Icons.lock_open),
              )
          ],
          ),
        body: TabBarView(

          children: <Widget>[
            PresensiSaya(),
            TakePictureScreen(),
          ],
          ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              style: BorderStyle.none
        )
          ),
          tabs: <Widget>[
            Tab(
              icon : Icon(Icons.home),
              text : "Home"
            ),
            Tab(
              icon : Icon(Icons.camera),
              text : "Camera"
            ),
          ],
        ),
      ),
    );
  }
}