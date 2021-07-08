import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:geo_snap/backend/user.dart';
import 'package:geo_snap/backend/user_model.dart';

import 'package:geo_snap/pages/preferences_drawer.dart';
import 'package:geo_snap/pages/edit_page.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The 'Profile' page is where users can view and edit their personal        *
 * profiles. From this page users can view their created username, location, *
 * description, profile picture, and posted snaps. Users can also edit and   *
 * change preferences for the app from this page.                            *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

bool _isLoggedIn = false;
String _location = "";
String _description = "";
GeoSnapUser currentUser;
List posts;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        setState(() {
          _isLoggedIn = false;
        });
      } else {
        print('User is signed in!');
      }
    });
    User user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoggedIn = false;
      });
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: _isLoggedIn != false ? Text(widget.title) : Text("Logged Out"),
      ),
      body: _isLoggedIn != false ? profilePage() : notLoggedIn(),
      endDrawer: Drawer(
        child: PreferencesDrawer(),
      ),
    );
  }

  /*
   * Widget that shows when there is not active user logged in to the app.
   * Currently just shows text asking the user to log into the app.
   */
  Widget notLoggedIn() {
    return Center(
      child: RaisedButton(
        child: Text(
          'Log In/Register',
          style: TextStyle(
              //color: Colors.white,
              ),
        ),
        onPressed: () {
          _showLoginPage();
        },
      ),
    );
  }

  _showLoginPage() async {
    final result = await Navigator.pushNamed(context, '/loginPage');
    setState(() {
      if (result == null) {
        _isLoggedIn = _isLoggedIn;
      } else {
        _isLoggedIn = result;
      }
    });
  }

  /*
   * profilePage() shows the currently active logged in user's custom profile.
   * Shows many attributes of the user such as their display name and 
   * profile pic.
   */
  Widget profilePage() {
    final _model = UserModel();
    User user = FirebaseAuth.instance.currentUser;

    /*
     * Needs to wait for UserModel to fetch the user from the firebase cloud db
     * in order to set the current active user of the profile page.
     * This is required as the built-in firebase authentication User class does
     * not have extra fields for things like a description or location. 
     * This method checks the current logged in authenticated user against the
     * users stored in the firebase cloud db by querying their User ID and
     * fetches the users relevent information. 
     */
    _model.getGeoSnapUser(user).whenComplete(() {
      if (currentUser != _model.currentUser) {
        currentUser = _model.currentUser;
      }

      if (_location != currentUser.location ||
          _description != currentUser.description) {
        setState(() {
          _location = currentUser.location;
          _description = currentUser.description;
        });
      }

      if (posts != currentUser.postsURL) {
        posts = currentUser.postsURL;
      }
    });

    String _username = user.displayName;

    String _profileImage = user.photoURL;

    // _edit() calls when edit button is pressed in order to change user info
    Future<void> _edit() async {
      currentUser = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditPage(currentUser: currentUser)));
      if (currentUser != null) {
        _model.editGeoSnapUser(currentUser).whenComplete(() {
          setState(() {});
        });
      } else {
        _model.getGeoSnapUser(user).whenComplete(() {
          if (currentUser != _model.currentUser) {
            currentUser = _model.currentUser;
          }
        });
      }
    }

    return Container(
      child: ListView(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 14),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    _profileImage,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          _username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 18,
                            ),
                            Text(
                              _location,
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        trailing: RaisedButton(
                          onPressed: () {
                            _edit();
                          },
                          color: Colors.blueGrey[200],
                          child: Text(
                            FlutterI18n.translate(context, "profile.edit"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _description,
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.blueGrey[300],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Snapshots',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  itemCount: posts != null ? posts.length : 0,
                  primary: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 0,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        child: posts != null
                            ? GridTile(
                                child: Image.network(posts[index],
                                    fit: BoxFit.fill))
                            : GridTile(child: Container()));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
