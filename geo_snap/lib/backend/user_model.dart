import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:geo_snap/backend/user.dart';

/*
 * UserModel class is what interacts with firebase authentication and firebase
 * cloud db in order to add a new user, set their location/description/posts, 
 * query for a specific user based on their UID, and edit their information
 */
class UserModel with ChangeNotifier {
  GeoSnapUser currentUser;
  Future addUser(GeoSnapUser user) async {
    await FirebaseFirestore.instance.collection('users').add(user.toMap());
  }

  Future getGeoSnapUser(User user) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: user.uid)
        .get();

    currentUser = GeoSnapUser(
        user: user,
        location: result.docs[0].get("location"),
        description: result.docs[0].get("description"),
        postsURL: result.docs[0].get("posts"));
  }

  Future<void> editGeoSnapUser(GeoSnapUser someUser) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: someUser.uid)
        .get();
    String path = result.docs[0].reference.id;
    print(path);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    return user.doc(path).set(someUser.toMap());
  }

  Future<void> addPost(GeoSnapUser someUser, List posts) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: someUser.uid)
        .get();
    String path = result.docs[0].reference.id;
    print(path);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    return user
        .doc(path)
        .update({'posts': posts})
        .then((value) => print("Added Post"))
        .catchError((error) => print("Failed to update $error"));
  }

  Future<void> deleteUserPost(GeoSnapUser someUser, String deleteURL) async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: someUser.uid)
        .get();
    String path = result.docs[0].reference.id;
    List somelist = result.docs[0].get("posts");

    somelist.remove(deleteURL);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    return user
        .doc(path)
        .update({'posts': somelist})
        .then((value) => print("Added Post"))
        .catchError((error) => print("Failed to update $error"));
  }
}
