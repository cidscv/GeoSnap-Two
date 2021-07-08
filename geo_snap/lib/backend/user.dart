import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * GeoSnapUser class was made as the user class built-in to the                *
 * firebase authentication library only lets users set their display name and  *
 * profile picture (along with email, password, ect..) By creating this        *
 * GeoSnapUser class we can allow users to set their location and description  *
 * and also have an easier way to show the posts that the user has created     *
 * on their profile.                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
class GeoSnapUser {
  User user;
  String uid;
  String description;
  String location;
  List postsURL = [];
  DocumentReference reference;

  GeoSnapUser({User user, String description, String location, List postsURL}) {
    this.user = user;
    this.uid = user.uid;
    this.description = description;
    this.location = location;
    this.postsURL = postsURL;
  }

  GeoSnapUser.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.uid = map['uid'];
    this.description = map['description'];
    this.location = map['location'];
    this.postsURL = map['posts'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'description': this.description,
      'location': this.location,
      'posts': this.postsURL,
    };
  }

  String toString() {
    return 'USER{username: ${this.user.displayName}, id: ${this.uid}';
  }
}
