import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';

import 'package:geo_snap/backend/posts.dart';

/*
 * PostsModel class is what we use to interact with the firebase cloud db
 * in order to add a new post, update a post (likes), and delete a post
 */
class PostsModel with ChangeNotifier {
  Future insertPost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').add(post.toMap());
  }

  Future<void> deletePost(DocumentSnapshot postdata) async {
    final post = Post.fromMap(postdata.data(), reference: postdata.reference);
    post.reference.delete();
  }

  Future<void> updatePostLikes(String selectedindex, int numberlikes) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    return posts
        .doc(selectedindex)
        .update({'numlikes': numberlikes})
        .then((value) => print("Post updated"))
        .catchError((error) => print("Failed to update $error"));
  }

  Future<QuerySnapshot> getAllPosts() async {
    return await FirebaseFirestore.instance.collection('posts').get();
  }
}
