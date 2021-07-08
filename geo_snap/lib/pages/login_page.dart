import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:geo_snap/pages/login_form.dart';
import 'package:geo_snap/pages/registration_form.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showRegistrationForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GEO-SNAP'),
        centerTitle: true,
      ),
      body: _showForm(),
    );
  }

  Widget _showForm() {
    if (_showRegistrationForm) {
      return Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            RegistrationForm(),
            TextButton(
              child: Text(
                FlutterI18n.translate(context, "register.haveaccount"),
              ),
              onPressed: () {
                setState(() {
                  _showRegistrationForm = false;
                });
              },
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            LoginForm(),
            TextButton(
              child: Text(
                FlutterI18n.translate(context, "login.noaccount"),
              ),
              onPressed: () {
                setState(() {
                  _showRegistrationForm = true;
                });
              },
            ),
          ],
        ),
      );
    }
  }
}
