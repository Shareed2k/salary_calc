import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salary_calc/services/authentication.dart';

import 'clinic_list_page.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;

  LoginPage({this.auth});

  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isIos = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    widget.auth.getCurrentUser().then((user) {
      if (user != null) {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new ClinicPage(user: user),
          ),
        );
      }
    });
  }

  // Perform login or signup
  void _submit() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FirebaseUser user = await widget.auth.signIn();

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new ClinicPage(user: user),
            ),
        );
      }

    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        if (_isIos) {
          _errorMessage = e.details;
        } else
          _errorMessage = e.message;
      });
    }
  }

  //////// widgets ////////////

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: new GlobalKey<FormState>(),
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              //_showLogo(),
              _showPrimaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: new MaterialButton(
          elevation: 5.0,
          minWidth: 200.0,
          height: 42.0,
          color: Colors.blue,
          child: new Text('Google sign',
          style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: _submit,
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  /*Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/flutter-icon.png'),
        ),
      ),
    );
  }*/
}