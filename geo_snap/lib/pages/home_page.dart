import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:geo_snap/backend/posts.dart';
import 'package:geo_snap/backend/posts_model.dart';
import 'package:geo_snap/backend/user.dart';
import 'package:geo_snap/backend/user_model.dart';

import 'package:geo_snap/pages/chart_page.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The 'Home' page is where users can see theirs and other users posts.    *
 * Designed to be scrollable so that users can continue to see new posts.  *
 * Users can like posts that they find interesting.                        * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
GeoSnapUser currentUser;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _model = PostsModel();
  User user = FirebaseAuth.instance.currentUser;

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    if (user != null) {
      _isLoggedIn = true;
    }
  }

  List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          _isLoggedIn
              ? IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () {
                    downloadFile();
                  },
                )
              : TextButton(
                  child: Text(
                    FlutterI18n.translate(context, "login.loginpage"),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    _showLoginPage();
                  },
                ),
          IconButton(
            icon: Icon(Icons.bar_chart_outlined),
            onPressed: () {
              getDocuments();
            },
          ),
        ],
      ),
      body: _buildPostList(context),
    );
  }

  /*
   * _buildPostList(...) is a Widget that builds the list of posts shown on
   * the home screen, building one 'post' at a time using _buildPost widget
   * if no data can be shown, progress indicator is shown instead
   */
  Widget _buildPostList(BuildContext context) {
    final _model = PostsModel();
    return FutureBuilder(
      future: _model.getAllPosts(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return Container(
            child: ListView(
              children: snapshot.data.docs
                  .map((DocumentSnapshot document) =>
                      _buildPost(context, document))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  /*
   * _buildPost(..., ...) creates the UI of each individual post.
   * Each post has heart icon to 'like' post, shows amount of likes
   * each post has recieved, shows the title of the post, 
   * shows the user who posted along with their location and profile picture,
   * shows a drop down menu to edit and delete post if the post is made by
   * the user that is currently browsing the app, and finally shows the 
   * location where post was taken
   */
  Widget _buildPost(BuildContext context, DocumentSnapshot postData) {
    final _model = PostsModel();
    final _userModel = UserModel();

    if (user != null) {
      _userModel.getGeoSnapUser(user).whenComplete(() {
        if (currentUser != _userModel.currentUser) {
          currentUser = _userModel.currentUser;
        }
      });
    }
    final post = Post.fromMap(postData.data(), reference: postData.reference);
    String username = post.userName;
    String profilePhoto = post.userProfilePic;
    return Card(
      color: Colors.blueGrey[800],
      child: Column(
        children: <Widget>[
          ListTile(
              leading: Container(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    profilePhoto,
                  ),
                ),
              ),
              title: Container(
                child: Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              subtitle: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  Text(
                    post.location,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              trailing: user != null
                  ? post.userName == user.displayName
                      ? IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            size: 32,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _model.deletePost(postData);
                              _userModel.deleteUserPost(
                                  currentUser, post.imageURL);
                            });
                            final snackBar = SnackBar(
                              content: Text(
                                'Post Deleted',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor:
                                  Colors.blueGrey.withOpacity(0.85),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          },
                        )
                      : null
                  : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.network(
                post.imageURL,
                height: 350,
                width: 350,
                alignment: Alignment.centerLeft,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    size: 32,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    print("LIKED!");
                    setState(() {
                      _model.updatePostLikes(
                          post.reference.id, post.numlikes + 1);
                    });
                  },
                ),
                Text(
                  '${post.numlikes} likes',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*
   * downloadFile() function used to push page to 'add_snapshot.dart' page
   * takes post that is made in 'add_snapshot.dart' and inserts into FireBase
   * storage (post collection)
   */
  Future downloadFile() async {
    var post = await Navigator.pushNamed(context, '/addSnapshot');
    if (post != null) {
      setState(() {
        _model.insertPost(post);
      });
    }
  }

  /*
   * _showLoginPage() function used to push page to 'login_page.dart' page.
   * after a successful login, the user will return to the home page and 
   * will be able to add snapshots/view profile.
   */
  Future _showLoginPage() async {
    final result = await Navigator.pushNamed(context, '/loginPage');
    setState(() {
      if (result == null) {
        _isLoggedIn = _isLoggedIn;
      } else {
        _isLoggedIn = result;
      }
    });
  }

  Future<void> getDocuments() async {
    posts = List();
    _model.getAllPosts().then((value) {
      value.docs.forEach((element) {
        setState(() {
          if (posts.length < 10) {
            posts.add(
                Post.fromMap(element.data(), reference: element.reference));
            posts.sort((a, b) {
              return b.numlikes.compareTo(a.numlikes);
            });
          }
        });
      });
    }).whenComplete(() => _barChart());
  }

  void _barChart() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BarChartPage(),
            settings: RouteSettings(arguments: posts)));
  }
}
