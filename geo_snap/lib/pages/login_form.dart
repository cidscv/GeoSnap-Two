import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String username;
  String password;
  String email;
  FirebaseAuth auth = FirebaseAuth.instance;
  String error = "";

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "login.email"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (String value) {
                    email = value;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "login.password"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (String value) {
                    password = value;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  color: Colors.blueGrey,
                  child: Text(
                    FlutterI18n.translate(context, "login.login"),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (email != null && password != null) {
                      _login();
                      Navigator.pop(context);
                    } else {
                      final snackBar = SnackBar(
                        content: Text(
                          FlutterI18n.translate(context, "login.error"),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.blueGrey.withOpacity(0.85),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                      error = "Must include email and password";
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _login() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        final snackBar = SnackBar(
          content: Text(
            FlutterI18n.translate(context, "login.failure"),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueGrey.withOpacity(0.85),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        final snackBar = SnackBar(
          content: Text(
            FlutterI18n.translate(context, "login.wrong"),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueGrey.withOpacity(0.85),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        print('Failed with error code: ${e.code}');
        print(e.message);
      }
    }
  }
}
