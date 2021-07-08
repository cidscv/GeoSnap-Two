import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:geo_snap/backend/preferences.dart';
import 'package:geo_snap/backend/preferences_model.dart';

import 'package:geo_snap/backend/notifications.dart';

class PreferencesDrawer extends StatefulWidget {
  final model = PreferencesModel();

  @override
  _PreferencesDrawerState createState() => _PreferencesDrawerState();
}

class _PreferencesDrawerState extends State<PreferencesDrawer> {
  Preferences _preferences;
  String _languageValueDropdown;
  String _imageSizeDropdown;

  final _notifications = Notifications();
  String _title = "Logged Out";
  String _body = "You've been successfully logged out.";
  String _payload = "";

  void initState() {
    _initPreferences();
    _getAllPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _notifications.init();

    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.blueGrey[300],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Language'),
                    subtitle: Text(_preferences.language),
                    trailing: DropdownButton(
                      value: _languageValueDropdown,
                      items: <String>['English', 'French', 'Japanese']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String newLanguage) async {
                        setState(() {
                          _preferences.language = newLanguage;
                          _languageValueDropdown = newLanguage;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Image Size'),
                    subtitle: Text(_preferences.imageSize),
                    trailing: DropdownButton(
                      value: _imageSizeDropdown,
                      items: <String>['Small', 'Medium', 'Large']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String newSize) {
                        setState(() {
                          _preferences.imageSize = newSize;
                          _imageSizeDropdown = newSize;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () async {
                Preferences preferences = Preferences(
                    language: _languageValueDropdown,
                    imageSize: _imageSizeDropdown);
                _updatePreferences(preferences);
                if (preferences.language == 'French') {
                  Locale newLocale = Locale('fr');
                  await FlutterI18n.refresh(context, newLocale);
                  setState(() {});
                }
                if (preferences.language == 'English') {
                  Locale newLocale = Locale('en');
                  await FlutterI18n.refresh(context, newLocale);
                  setState(() {});
                }
                if (preferences.language == 'Japanese') {
                  Locale newLocale = Locale('ja');
                  await FlutterI18n.refresh(context, newLocale);
                  setState(() {});
                }
                final snackBar = SnackBar(
                  content: Text(
                    'Preferences have been updated!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.blueGrey.withOpacity(0.85),
                );
                Navigator.pop(context);
                Scaffold.of(context).showSnackBar(snackBar);
              },
              color: Colors.blueGrey[200],
              child: Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            RaisedButton(
              onPressed: () {
                _logout().whenComplete(
                  () => _notifications.sendNotificationNow(
                    _title,
                    _body,
                    _payload,
                  ),
                );
              },
              color: Colors.red,
              child: Text(
                'LOGOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  void _initPreferences() {
    Preferences preferencesInit =
        Preferences(language: 'English', imageSize: 'Small');
    widget.model.insertPreferences(preferencesInit);
    setState(() {
      _preferences = preferencesInit;
      _languageValueDropdown = preferencesInit.language;
      _imageSizeDropdown = preferencesInit.imageSize;
    });
  }

  void _updatePreferences(Preferences preferences) {
    preferences.id = 1;
    widget.model.updatePreferences(preferences);
  }

  Future<void> _getAllPreferences() async {
    List<Preferences> preferences = await widget.model.getAllPreferences();
    setState(() {
      _preferences = preferences[0];
      _languageValueDropdown = _preferences.language;
      _imageSizeDropdown = _preferences.imageSize;
    });
  }
}
