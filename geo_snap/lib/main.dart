import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:geo_snap/pages/chart_page.dart';
import 'package:geo_snap/pages/profile_page.dart';

import 'pages/add_snapshot.dart';
import 'package:geo_snap/pages/home_page.dart';
import 'pages/login_page.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Geo-Snap                                                        *
 * Created by Austin Oligario, Owen Reid, and Jayson Sandhu        *
 * Current Version: Dev 2.0.2                                      *
 * Dependencies: Flutter, FireBase Core, FireBase Authentication,  *
 *               FireBase Storage, FireBase Cloud Storage, SQFlite *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/flutter_i18n'),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);
  runApp(MyApp(flutterI18nDelegate));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;
  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error initalizing firebase");
          return Text("Error initalizing firebase");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Geo-Snap',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: Colors.blueGrey[900],
            ),
            home: BottomNav(),
            localizationsDelegates: [
              flutterI18nDelegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            routes: <String, WidgetBuilder>{
              '/addSnapshot': (BuildContext context) => AddSnap(
                  title: FlutterI18n.translate(context, "title.addsnap")),
              '/homePage': (BuildContext context) =>
                  HomePage(title: 'GEO-SNAP'),
              '/profilePage': (BuildContext context) => ProfilePage(
                  title: FlutterI18n.translate(context, "title.profile")),
              '/loginPage': (BuildContext context) => LoginPage(
                  title: FlutterI18n.translate(context, "title.login")),
              '/chartPage': (BuildContext context) =>
                  BarChartPage(title: 'BarChart'),
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  bool _isLoggedIn = false;
  int _selectedIndex = 0;
  List<Widget> _pages = [
    HomePage(title: 'GEO-SNAP'),
    ProfilePage(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        _isLoggedIn = false;
      } else {
        print('User is signed in!');
        if (_isLoggedIn != true) {
          setState(() {
            _isLoggedIn = true;
          });
        }
      }
    });

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[900],
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
            ),
          ],
          border: Border(
            top: BorderSide(width: 1, color: Colors.blueGrey),
          ),
        ),
        child: Container(
          height: 50,
          child: buildNavItems(),
        ),
        // BottomNavigationBar(
        //   backgroundColor: Colors.blueGrey[900],
        //   items: <Widget>[
        //     buildNavItems(),
        //   ],
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: Colors.white70,
        //   unselectedItemColor: Colors.blueGrey[700],
        //   onTap: _onItemTapped,
        // ),
      ),
    );
  }

  Widget buildNavItems() {
    if (_isLoggedIn) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.home,
                  size: 25,
                  color: _selectedIndex == 0 ? Colors.white : Colors.blueGrey,
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: _selectedIndex == 0 ? Colors.white : Colors.blueGrey,
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          FlatButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 25,
                  color: _selectedIndex == 1 ? Colors.white : Colors.blueGrey,
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: _selectedIndex == 1 ? Colors.white : Colors.blueGrey,
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.home,
                  size: 25,
                  color: _selectedIndex == 0 ? Colors.white : Colors.blueGrey,
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: _selectedIndex == 0 ? Colors.white : Colors.blueGrey,
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
        ],
      );
    }
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }
}
