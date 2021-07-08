import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Post class is used to create a new instance of a post in order to create    * 
 * the fields on the firebase cloud db. Saves info such as the user who        *
 * created the post, the title, the number of likes                            *
 * (which can be updated through postmodel class and cloud firestore library), *
 * and the location the post was taken.                                        *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

class Post {
  Post({
    String title,
    String imageURL,
    int numlikes,
    String location,
  }) {
    this.title = title;
    this.numlikes = numlikes;
    this.imageURL = imageURL;
    this.userName = user.displayName;
    this.userProfilePic = user.photoURL;
    this.location = location;
  }

  User user = FirebaseAuth.instance.currentUser;
  String title;
  String imageURL;
  int numlikes;
  String userName;
  String userProfilePic;
  String location;
  DocumentReference reference;

  Post.fromMap(Map<String, dynamic> map, {this.reference}) {
    this.title = map['title'];
    this.imageURL = map['imageURL'];
    this.numlikes = map['numlikes'];
    this.userName = map['userName'];
    this.userProfilePic = map['userProfilePic'];
    this.location = map['location'];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': this.title,
      'imageURL': this.imageURL,
      'numlikes': this.numlikes,
      'userName': this.userName,
      'userProfilePic': this.userProfilePic,
      'location': this.location,
    };
  }
}
